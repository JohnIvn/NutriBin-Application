import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:permission_handler/permission_handler.dart';

class RegisterMachinePage extends StatefulWidget {
  const RegisterMachinePage({super.key});

  @override
  State<RegisterMachinePage> createState() => _RegisterMachinePageState();
}

class _RegisterMachinePageState extends State<RegisterMachinePage> {
  // Controllers
  final _machineNameController = TextEditingController();
  final _machineIdController = TextEditingController();
  final _wifiNameController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  // ignore: unused_field
  bool _isLoading = false;
  bool _isBluetoothScanning = false;
  bool _isBluetoothConnecting = false;
  bool _isProvisioningWifi = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _selectedBluetoothDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  StreamSubscription<List<ScanResult>>? _discoverySubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  String? _bluetoothStatus;
  StateSetter? _pairingSheetSetState;
  BuildContext? _pairingSheetContext;

  Future<void> _showBluetoothPairing() async {
    final ready = await _prepareBluetoothForProvisioning();
    if (!ready) {
      return;
    }

    if (_scanResults.isEmpty && !FlutterBluePlus.isScanningNow) {
      await _startBluetoothDiscovery();
    }

    if (!mounted) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _pairingSheetSetState = setModalState;
            _pairingSheetContext = modalContext;
            final primaryColor = Theme.of(context).colorScheme.primary;
            final textColor = Theme.of(context).colorScheme.onSurface;
            final subTextColor =
                Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
            final bgColor = Theme.of(context).scaffoldBackgroundColor;
            final hasConnectedDevice =
                _selectedBluetoothDevice != null &&
                _writeCharacteristic != null;

            final connectedDeviceName = hasConnectedDevice
                ? _displayBluetoothName(_selectedBluetoothDevice!)
                : null;

            final discoveredDevices = _scanResults
                .map((result) => result.device)
                .toList();

            final hasAnyDevices = discoveredDevices.isNotEmpty;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BLE Pairing',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor),
                            onPressed: () {
                              _stopBluetoothDiscovery();
                              Navigator.pop(modalContext);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_bluetoothStatus != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: subTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _bluetoothStatus!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: subTextColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!hasAnyDevices)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isBluetoothScanning)
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: primaryColor,
                                        ),
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
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Make sure your NutriBin is powered on and advertising BLE.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: subTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  0,
                                ),
                                children: [
                                  Text(
                                    'Discovered NutriBins',
                                    style: GoogleFonts.interTight(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  for (final device in discoveredDevices) ...[
                                    _buildBluetoothDeviceTile(
                                      device: device,
                                      primaryColor: primaryColor,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                    ),
                                    Divider(
                                      height: 1,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ],
                                ],
                              ),
                            if (hasConnectedDevice)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connected: $connectedDeviceName',
                                      style: GoogleFonts.interTight(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                      controller: _wifiNameController,
                                      label: 'Wi-Fi Name (SSID)',
                                      hint: 'e.g. Home_Wifi_2.4G',
                                      icon: Icons.wifi_rounded,
                                      isDarkMode:
                                          Theme.of(context).brightness ==
                                          Brightness.dark,
                                      primaryColor: primaryColor,
                                      cardColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black12
                                          : Colors.grey[100]!,
                                      textColor: textColor,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                      controller: _wifiPasswordController,
                                      label: 'Wi-Fi Password',
                                      hint: 'Enter Wi-Fi password',
                                      icon: Icons.lock_rounded,
                                      isObscure: true,
                                      isDarkMode:
                                          Theme.of(context).brightness ==
                                          Brightness.dark,
                                      primaryColor: primaryColor,
                                      cardColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black12
                                          : Colors.grey[100]!,
                                      textColor: textColor,
                                    ),
                                    const SizedBox(height: 12),
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
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(Icons.send_rounded),
                                        label: Text(
                                          _isProvisioningWifi
                                              ? 'Sending Wi-Fi Credentials...'
                                              : 'Send Wi-Fi Credentials',
                                          style: GoogleFonts.interTight(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: SizedBox(
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
                                    _isBluetoothScanning
                                        ? 'Stop Scanning'
                                        : 'Scan for Devices',
                                    style: GoogleFonts.interTight(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    _pairingSheetContext = null;
    _pairingSheetSetState = null;
    _stopBluetoothDiscovery();
  }

  void _refreshBluetoothUi() {
    if (!mounted) {
      return;
    }
    setState(() {});
    _pairingSheetSetState?.call(() {});
  }

  void _closeBluetoothPairingSheet() {
    final sheetContext = _pairingSheetContext;
    _pairingSheetContext = null;
    _pairingSheetSetState = null;

    if (sheetContext != null && Navigator.of(sheetContext).canPop()) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _loadBondedDevices() async {
    // BLE doesn't strictly use "bonded" list the same way for discovery.
    // We rely on active scans.
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
    if (_isBluetoothScanning) {
      return;
    }

    final ready = await _prepareBluetoothForProvisioning();
    if (!ready) {
      return;
    }

    await _stopBluetoothDiscovery();

    _scanResults = [];
    _isBluetoothScanning = true;
    _bluetoothStatus = 'Scanning for nearby NutriBins...';
    _refreshBluetoothUi();

    _discoverySubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        _scanResults = results
            .where((r) => _isNutriBinNamedDevice(r.device))
            .toList();
        _refreshBluetoothUi();
      },
      onError: (Object error) {
        _bluetoothStatus = 'Discovery error: $error';
        _isBluetoothScanning = false;
        _refreshBluetoothUi();
      },
    );

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid('4fafc201-1fb5-459e-8fcc-c5c9c331914b')],
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      _isBluetoothScanning = false;
      _bluetoothStatus = 'Scan failed: $e';
      _refreshBluetoothUi();
    }

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isBluetoothScanning) {
        _isBluetoothScanning = false;
        _bluetoothStatus = _scanResults.isEmpty
            ? 'Scan finished. No NutriBins found.'
            : 'Scan finished. Select a device.';
        _refreshBluetoothUi();
      }
    });
  }

  Future<void> _stopBluetoothDiscovery() async {
    await FlutterBluePlus.stopScan();
    await _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _isBluetoothScanning = false;
    _refreshBluetoothUi();
  }

  String _displayBluetoothName(BluetoothDevice device) {
    final name = device.platformName.trim();
    return name.isEmpty ? 'Unknown BLE Device' : name;
  }

  bool _isNutriBinNamedDevice(BluetoothDevice device) {
    final name = device.platformName.trim().toLowerCase();
    return name == 'nutribin' || name.startsWith('nutribin-');
  }

  String _friendlyBluetoothConnectError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('timeout')) {
      return 'BLE connection timed out. Keep device close and try again.';
    }

    if (message.contains('permission')) {
      return 'Bluetooth permission error. Re-grant permissions in settings.';
    }

    if (message.contains('bond') ||
        message.contains('pairing') ||
        message.contains('authentication')) {
      return 'Pairing failed. Check the pairing dialog on your device and try again.';
    }

    if (message.contains('gatt') ||
        message.contains('service') ||
        message.contains('characteristic')) {
      return 'Device does not have required BLE services. Ensure device is in pairing mode.';
    }

    return 'BLE connection failed. Please retry.';
  }

  Widget _buildBluetoothDeviceTile({
    required BluetoothDevice device,
    required Color primaryColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final isConnected = _selectedBluetoothDevice?.remoteId == device.remoteId;
    final leadingIcon = Icons.recycling_rounded;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(
        leadingIcon,
        color: isConnected ? Colors.green : primaryColor,
      ),
      title: Text(
        _displayBluetoothName(device),
        style: GoogleFonts.interTight(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        device.remoteId.str,
        style: GoogleFonts.inter(fontSize: 12, color: subTextColor),
      ),
      trailing: isConnected
          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
          : TextButton(
              onPressed: _isBluetoothConnecting
                  ? null
                  : () => _connectToBluetoothDevice(device),
              child: Text(
                'Connect',
                style: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }

  Future<void> _connectToBluetoothDevice(BluetoothDevice device) async {
    if (_isBluetoothConnecting) {
      return;
    }

    _isBluetoothConnecting = true;
    _bluetoothStatus = 'Connecting to ${_displayBluetoothName(device)}...';
    _refreshBluetoothUi();

    await _stopBluetoothDiscovery();

    try {
      print('[DEBUG] === Starting BLE Connection ===');
      print('[DEBUG] Device: ${device.remoteId} (${device.platformName})');

      // Step 1: Connect to device
      _bluetoothStatus = 'Connecting to ${_displayBluetoothName(device)}...';
      _refreshBluetoothUi();
      print('[DEBUG] Calling device.connect() with 15s timeout...');
      await device.connect(timeout: const Duration(seconds: 15));
      print('[DEBUG] ✓ Connected to device: ${device.remoteId}');

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        print('[DEBUG] Connection state changed: $state');
        if (state == BluetoothConnectionState.disconnected) {
          print('[DEBUG] Device disconnected!');
          _selectedBluetoothDevice = null;
          _writeCharacteristic = null;
          _notifyCharacteristic = null;
          _bluetoothStatus = 'Disconnected';
          _refreshBluetoothUi();
        }
      });

      // Step 3: Discover services
      _bluetoothStatus =
          'Discovering services on ${_displayBluetoothName(device)}...';
      _refreshBluetoothUi();
      print('[DEBUG] Starting service discovery...');

      List<BluetoothService> services = await device.discoverServices();
      print('[DEBUG] ✓ Discovered ${services.length} services');
      if (services.isEmpty) {
        throw Exception('No GATT services found on device.');
      }

      // Step 4: Find required characteristics
      for (var service in services) {
        print('[DEBUG] Service: ${service.uuid}');
        if (service.uuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914b') {
          for (var characteristic in service.characteristics) {
            print(
              '[DEBUG]   └─ Char: ${characteristic.uuid}, Write: ${characteristic.properties.write}, WriteNoResp: ${characteristic.properties.writeWithoutResponse}',
            );
            if (characteristic.uuid.toString() ==
                'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
              _writeCharacteristic = characteristic;
              print(
                '[DEBUG]   ✓ Found NutriBin WRITE characteristic: ${characteristic.uuid}',
              );
            }
            if (characteristic.properties.notify ||
                characteristic.properties.indicate) {
              _notifyCharacteristic =
                  characteristic; // Optional feature for future use
            }
          }
        }
      }

      if (_writeCharacteristic != null) {
        _selectedBluetoothDevice = device;
        _bluetoothStatus = 'Connected to ${_displayBluetoothName(device)}';
        _showSnackBar('Connected to ${_displayBluetoothName(device)}');
        print('[DEBUG] ✓ Successfully connected and ready for provisioning');

        if (_notifyCharacteristic != null) {
          await _notifyCharacteristic!.setNotifyValue(true);
          print('[DEBUG] ✓ Enabled notifications');
        }

        _closeBluetoothPairingSheet();
      } else {
        await device.disconnect();
        throw Exception('Required BLE characteristics not found.');
      }
    } catch (error, stackTrace) {
      print('[ERROR] ✗ Connection error: $error');
      print('[ERROR] Stack trace:\n$stackTrace');
      final friendly = _friendlyBluetoothConnectError(error);
      _bluetoothStatus = friendly;
      _showSnackBar(friendly);
    } finally {
      _isBluetoothConnecting = false;
      _refreshBluetoothUi();
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

    _isProvisioningWifi = true;
    _bluetoothStatus = 'Sending Wi-Fi credentials...';
    _refreshBluetoothUi();

    try {
      final payload = jsonEncode({
        'type': 'wifi_config',
        'ssid': ssid,
        'password': password,
      });

      final value = utf8.encode('$payload\n');

      // Try withResponse first as it is more standard for GATT writes.
      // If it fails with GATT_UNLIKELY, we will know for sure if the server is rejecting it.
      await char.write(value, withoutResponse: false);

      _bluetoothStatus = 'Wi-Fi credentials sent. Closing...';
      _refreshBluetoothUi();

      // Give the user a moment to see the success message
      await Future.delayed(const Duration(seconds: 1));

      if (mounted && _pairingSheetContext != null) {
        Navigator.pop(_pairingSheetContext!);
      }

      _showSnackBar('Wi-Fi credentials sent. Machine is connecting...');
    } catch (error) {
      _bluetoothStatus = 'Failed to send over BLE: $error';
      _showSnackBar('Failed to send Wi-Fi credentials.');
    } finally {
      _isProvisioningWifi = false;
      _refreshBluetoothUi();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      final scannedCode = barcode.rawValue!;
                      setState(() {
                        _machineIdController.text = scannedCode;
                      });
                      Navigator.pop(context);

                      // Show a brief message before triggering registration
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Processing QR Code..."),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Automatically trigger registration
                      _handleRegisterMachine();
                      break;
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _discoverySubscription?.cancel();
    _connectionSubscription?.cancel();
    _pairingSheetSetState = null;
    _machineNameController.dispose();
    _machineIdController.dispose();
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- APP BAR CONFIG ---
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        systemOverlayStyle: SystemUiOverlayStyle.light,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: appBarContentColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register Machine',
          style: GoogleFonts.interTight(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appBarContentColor,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.transparent, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Device',
                style: GoogleFonts.interTight(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect your NutriBin to start monitoring.',
                style: GoogleFonts.inter(fontSize: 14, color: subTextColor),
              ),
              const SizedBox(height: 24),

              _buildSectionCard(
                context: context,
                title: 'Pair via Bluetooth',
                subtitle:
                    'Find your NutriBin, connect, then send your phone Wi-Fi credentials.',
                icon: Icons.bluetooth_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showBluetoothPairing,
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: Text(
                      'Scan for Devices',
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                context: context,
                title: 'Scan QR Code',
                subtitle:
                    'Scan the QR code on your NutriBin machine to register it automatically.',
                icon: Icons.qr_code_scanner_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showScanner,
                    icon: const Icon(Icons.center_focus_weak_rounded),
                    label: Text(
                      'Open QR Scanner',
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                context: context,
                title: 'Manual Entry',
                subtitle:
                    'Enter your machine details and Wi-Fi credentials manually.',
                icon: Icons.edit_note_rounded,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _machineIdController,
                      label: 'Machine ID',
                      hint: 'e.g. NB-123456',
                      icon: Icons.fingerprint_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _wifiNameController,
                      label: 'Wi-Fi Name (SSID)',
                      hint: 'e.g. Home_Wifi_2.4G',
                      icon: Icons.wifi_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _wifiPasswordController,
                      label: 'Wi-Fi Password',
                      hint: 'Enter Wi-Fi password',
                      icon: Icons.lock_rounded,
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      cardColor: isDarkMode ? Colors.black12 : Colors.grey[50]!,
                      textColor: textColor,
                      isObscure: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProvisioningWifi
                            ? null
                            : _sendWifiCredentials,
                        icon: _isProvisioningWifi
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.wifi_tethering_rounded),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        label: Text(
                          _isProvisioningWifi
                              ? 'Sending Wi-Fi Credentials...'
                              : 'Send Wi-Fi to Connected Device',
                          style: GoogleFonts.interTight(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegisterMachine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Register Machine",
                                style: GoogleFonts.interTight(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        // Dark Mode: Subtle border, no shadow
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : null,
        // Light Mode: Subtle shadow
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDarkMode ? Colors.white : primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.interTight(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    required Color primaryColor,
    required Color cardColor, // Background color for input
    required Color textColor,
    bool isObscure = false,
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

  Future<void> _handleRegisterMachine() async {
    final serialId = _machineIdController.text.trim();

    if (serialId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Machine ID is required")));
      return;
    }

    setState(() => _isLoading = true);

    final response = await MachineService.registerMachine(serialId: serialId);

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    if (response["ok"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Machine registered")),
      );
      await MachineService.fetchExistingMachines();

      if (!mounted) {
        return;
      }

      _machineIdController.clear();
      _wifiNameController.clear();
      _wifiPasswordController.clear();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Registration failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
