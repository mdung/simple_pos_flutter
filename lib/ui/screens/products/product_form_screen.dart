import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _skuController.text = widget.product!.sku;
      _priceController.text = widget.product!.price.toString();
      _costController.text = widget.product!.cost?.toString() ?? '';
      _categoryController.text = widget.product!.category;
      _stockController.text = widget.product!.stock.toString();
      _barcodeController.text = widget.product!.barcode ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);

      if (widget.product != null) {
        // Update existing product
        final updatedProduct = widget.product!.copyWith(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          cost: _costController.text.trim().isEmpty
              ? null
              : double.parse(_costController.text.trim()),
          category: _categoryController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
          updatedAt: DateTime.now(),
        );
        await provider.updateProduct(updatedProduct);
      } else {
        // Create new product
        await provider.createProduct(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          cost: _costController.text.trim().isEmpty
              ? null
              : double.parse(_costController.text.trim()),
          category: _categoryController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null
                  ? 'Product updated successfully'
                  : 'Product created successfully',
            ),
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

  Future<void> _deleteProduct() async {
    if (widget.product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProduct),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .deleteProduct(widget.product!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null
              ? AppStrings.editProduct
              : AppStrings.addProduct,
        ),
        actions: widget.product != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteProduct,
                  color: AppColors.error,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InputField(
              label: AppStrings.productName,
              controller: _nameController,
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.productName),
            ),
            const SizedBox(height: 16),
            InputField(
              label: AppStrings.sku,
              controller: _skuController,
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.sku),
            ),
            const SizedBox(height: 16),
            InputField(
              label: AppStrings.price,
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) =>
                  Validators.positiveNumber(value, fieldName: AppStrings.price),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            InputField(
              label: '${AppStrings.cost} (Optional)',
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => value != null && value.isNotEmpty
                  ? Validators.positiveNumber(value, fieldName: AppStrings.cost)
                  : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            InputField(
              label: AppStrings.category,
              controller: _categoryController,
              validator: (value) =>
                  Validators.required(value, fieldName: AppStrings.category),
            ),
            const SizedBox(height: 16),
            InputField(
              label: AppStrings.stock,
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final required = Validators.required(value, fieldName: AppStrings.stock);
                if (required != null) return required;
                final numeric = Validators.numeric(value, fieldName: AppStrings.stock);
                if (numeric != null) return numeric;
                final intValue = int.tryParse(value!);
                if (intValue == null || intValue < 0) {
                  return '${AppStrings.stock} must be a non-negative integer';
                }
                return null;
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            InputField(
              label: '${AppStrings.barcode} (Optional)',
              controller: _barcodeController,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: AppStrings.save,
              onPressed: _saveProduct,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

