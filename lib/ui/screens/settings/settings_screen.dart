import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    await provider.loadSettings();
    final settings = provider.settings;
    if (settings != null) {
      setState(() {
        _shopNameController.text = settings.shopName;
        _addressController.text = settings.address ?? '';
        _phoneController.text = settings.phone ?? '';
        _taxRateController.text = settings.taxRate.toString();
        _currencyController.text = settings.currencySymbol;
      });
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxRateController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<SettingsProvider>(context, listen: false);
      final currentSettings = provider.settings;

      if (currentSettings != null) {
        await provider.saveSettings(
          currentSettings.copyWith(
            shopName: _shopNameController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            taxRate: double.parse(_taxRateController.text.trim()),
            currencySymbol: _currencyController.text.trim(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.saved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  AppStrings.shopInfo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InputField(
                  label: AppStrings.shopName,
                  controller: _shopNameController,
                  validator: (value) =>
                      Validators.required(value, fieldName: AppStrings.shopName),
                ),
                const SizedBox(height: 16),
                InputField(
                  label: '${AppStrings.address} (Optional)',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: '${AppStrings.phone} (Optional)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tax & Currency',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InputField(
                  label: AppStrings.taxRate,
                  controller: _taxRateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final required = Validators.required(value, fieldName: AppStrings.taxRate);
                    if (required != null) return required;
                    final numeric = Validators.numeric(value, fieldName: AppStrings.taxRate);
                    if (numeric != null) return numeric;
                    final rate = double.parse(value!);
                    if (rate < 0 || rate > 100) {
                      return 'Tax rate must be between 0 and 100';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 16),
                InputField(
                  label: AppStrings.currency,
                  controller: _currencyController,
                  validator: (value) =>
                      Validators.required(value, fieldName: AppStrings.currency),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: AppStrings.save,
                  onPressed: _saveSettings,
                  isLoading: _isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

