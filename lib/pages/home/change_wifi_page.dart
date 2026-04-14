import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeWifiPage extends StatefulWidget {
  const ChangeWifiPage({super.key});

  @override
  State<ChangeWifiPage> createState() => _ChangeWifiPageState();
}

class _ChangeWifiPageState extends State<ChangeWifiPage> {
  final _wifiNameController = TextEditingController();
  final _wifiPasswordController = TextEditingController();

  bool _isBluetoothScanning = false;
  bool _isBluetoothConnecting = false;
  bool _isProvisioningWifi = false;
  bool _isWifiPasswordObscured = true;
  String? _bluetoothStatus;

  List<ScanResult> _scanResults = [];
  BluetoothDevice? _selectedBluetoothDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamSubscription<List<ScanResult>>? _discoverySubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _startBluetoothDiscovery();
  }

  @override
  void dispose() {
    _stopBluetoothDiscovery();
    _connectionSubscription?.cancel();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _ensureBluetoothPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((status) => status.isGranted);
    if (!allGranted) {
      _showSnackBar('BLE and location permissions are required.');
      return false;
    }
    return true;
  }

  Future<bool> _prepareBluetoothForProvisioning() async {
    final permissionsGranted = await _ensureBluetoothPermissions();
    if (!permissionsGranted) {
      return false;
    }

    if (!await FlutterBluePlus.isSupported) {
      _showSnackBar('BLE is not supported on this device.');
      return false;
    }

    // Check if adapter is on
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        _showSnackBar('Please enable Bluetooth in settings.');
        return false;
      }
    }

    final locationServiceStatus = await Permission.location.serviceStatus;
    if (!locationServiceStatus.isEnabled) {
      _showSnackBar('Turn on Location services to improve BLE discovery.');
    }

    return true;
  }

  Future<void> _startBluetoothDiscovery() async {
    if (_isBluetoothScanning) return;

    final ready = await _prepareBluetoothForProvisioning();
    if (!ready) return;

    await _stopBluetoothDiscovery();

    setState(() {
      _scanResults = [];
      _isBluetoothScanning = true;
      _bluetoothStatus = 'Scanning for nearby NutriBins...';
    });

    _discoverySubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        if (!mounted) return;
        setState(() {
          _scanResults = results
              .where((r) => _isNutriBinNamedDevice(r.device))
              .toList();
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _bluetoothStatus = 'Discovery error: $error';
          _isBluetoothScanning = false;
        });
      },
    );

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b')],
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isBluetoothScanning = false;
        _bluetoothStatus = 'Scan failed: $e';
      });
    }

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isBluetoothScanning) {
        setState(() {
          _isBluetoothScanning = false;
          _bluetoothStatus = _scanResults.isEmpty
              ? 'Scan finished. No NutriBins found.'
              : 'Scan finished. Select a device.';
        });
      }
    });
  }

  Future<void> _stopBluetoothDiscovery() async {
    await FlutterBluePlus.stopScan();
    await _discoverySubscription?.cancel();
    _discoverySubscription = null;
    if (mounted) {
      setState(() {
        _isBluetoothScanning = false;
      });
    }
  }

  String _displayBluetoothName(BluetoothDevice device) {
    final name = device.platformName.trim();
    return name.isEmpty ? 'Unknown BLE Device' : name;
  }

  bool _isNutriBinNamedDevice(BluetoothDevice device) {
    final name = device.platformName.trim().toLowerCase();
    return name == 'nutribin' || name.startsWith('nutribin-');
  }

  Future<void> _connectToBluetoothDevice(BluetoothDevice device) async {
    if (_isBluetoothConnecting) return;

    setState(() {
      _isBluetoothConnecting = true;
      _bluetoothStatus = 'Connecting to ${_displayBluetoothName(device)}...';
    });

    await _stopBluetoothDiscovery();

    try {
      await device.connect(timeout: const Duration(seconds: 15));

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && mounted) {
          setState(() {
            _selectedBluetoothDevice = null;
            _writeCharacteristic = null;
            _notifyCharacteristic = null;
            _bluetoothStatus = 'Disconnected';
          });
        }
      });

      setState(() {
        _bluetoothStatus =
            'Discovering services on ${_displayBluetoothName(device)}...';
      });

      List<BluetoothService> services = await device.discoverServices();
      if (services.isEmpty)
        throw Exception('No GATT services found on device.');

      for (var service in services) {
        if (service.uuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914b') {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() ==
                'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
              _writeCharacteristic = characteristic;
            }
            if (characteristic.properties.notify ||
                characteristic.properties.indicate) {
              _notifyCharacteristic = characteristic;
            }
          }
        }
      }

      if (_writeCharacteristic != null) {
        setState(() {
          _selectedBluetoothDevice = device;
          _bluetoothStatus = 'Connected to ${_displayBluetoothName(device)}';
        });
        _showSnackBar('Connected to ${_displayBluetoothName(device)}');

        if (_notifyCharacteristic != null) {
          await _notifyCharacteristic!.setNotifyValue(true);
        }
      } else {
        await device.disconnect();
        throw Exception('Required BLE characteristics not found.');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _bluetoothStatus = 'BLE connection failed: $error';
        });
        _showSnackBar('BLE connection failed. Please retry.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBluetoothConnecting = false;
        });
      }
    }
  }

  Future<void> _sendWifiCredentials() async {
    final ssid = _wifiNameController.text.trim();
    final password = _wifiPasswordController.text;

    if (ssid.isEmpty || password.isEmpty) {
      _showSnackBar('Wi-Fi name and password are required.');
      return;
    }

    final char = _writeCharacteristic;
    if (char == null) {
      _showSnackBar('Connect to a BLE device first.');
      return;
    }

    setState(() {
      _isProvisioningWifi = true;
      _bluetoothStatus = 'Sending Wi-Fi credentials...';
    });

    try {
      final payload = jsonEncode({
        'type': 'wifi_config',
        'ssid': ssid,
        'password': password,
      });

      final value = utf8.encode('$payload\n');

      try {
        await char.write(value, withoutResponse: false);
      } catch (e) {
        print('[DEBUG] BLE write error ignored. $e');
      }

      setState(() {
        _bluetoothStatus = 'Wi-Fi credentials sent.';
      });
      _showSnackBar('Wi-Fi credentials sent. Machine will now connect.');

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      setState(() {
        _bluetoothStatus = 'Failed to send over BLE: $error';
      });
      _showSnackBar('Failed to send Wi-Fi credentials.');
    } finally {
      if (mounted) {
        setState(() {
          _isProvisioningWifi = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.inter(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: textColor.withOpacity(0.3)),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isDarkMode
                  ? Colors.white70
                  : primaryColor.withOpacity(0.7),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final bgColor = theme.scaffoldBackgroundColor;
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.black12 : Colors.grey[100]!;

    final hasConnectedDevice =
        _selectedBluetoothDevice != null && _writeCharacteristic != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Change Wi-Fi Network',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            if (_bluetoothStatus != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _bluetoothStatus!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            if (!hasConnectedDevice) ...[
              if (_scanResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      if (_isBluetoothScanning)
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      else
                        Icon(
                          Icons.bluetooth_disabled_rounded,
                          size: 64,
                          color: Colors.grey.withOpacity(0.35),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        _isBluetoothScanning
                            ? 'Scanning for nearby BLE devices...'
                            : 'No BLE devices found',
                        style: GoogleFonts.interTight(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ensure your NutriBin is powered on and near you.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _scanResults.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                  itemBuilder: (context, index) {
                    final device = _scanResults[index].device;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Icon(
                        Icons.recycling_rounded,
                        color: primaryColor,
                      ),
                      title: Text(
                        _displayBluetoothName(device),
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        device.remoteId.str,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: _isBluetoothConnecting
                            ? null
                            : () => _connectToBluetoothDevice(device),
                        child: Text(
                          'Connect',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBluetoothConnecting
                      ? null
                      : (_isBluetoothScanning
                            ? _stopBluetoothDiscovery
                            : _startBluetoothDiscovery),
                  icon: Icon(
                    _isBluetoothScanning
                        ? Icons.stop_rounded
                        : Icons.bluetooth_searching_rounded,
                  ),
                  label: Text(
                    _isBluetoothScanning ? 'Stop Scanning' : 'Scan for Devices',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected to ${_displayBluetoothName(_selectedBluetoothDevice!)}',
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _wifiNameController,
                      label: 'Wi-Fi Name (SSID)',
                      hint: 'e.g. Home_Wifi_2.4G',
                      icon: Icons.wifi_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _wifiPasswordController,
                      label: 'Wi-Fi Password',
                      hint: 'Enter Wi-Fi password',
                      icon: Icons.lock_rounded,
                      isObscure: _isWifiPasswordObscured,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                      textColor: textColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isWifiPasswordObscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: isDarkMode
                              ? Colors.white70
                              : primaryColor.withOpacity(0.7),
                        ),
                        onPressed: () => setState(
                          () => _isWifiPasswordObscured =
                              !_isWifiPasswordObscured,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProvisioningWifi
                            ? null
                            : _sendWifiCredentials,
                        icon: _isProvisioningWifi
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isProvisioningWifi
                              ? 'Sending...'
                              : 'Send Wi-Fi Credentials',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
