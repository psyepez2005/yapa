import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yapa/core/services/auth_service.dart';

class MerchantLoginScreen extends StatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  State<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends State<MerchantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  // Register extras
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  bool _loadingCategories = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _businessNameCtrl.dispose();
    _rucCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (_categories.isNotEmpty) return;
    setState(() => _loadingCategories = true);
    try {
      final cats = await _authService.fetchCategories();
      if (mounted) setState(() => _categories = cats);
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegisterMode && _selectedCategoryId == null) {
      _showError('Selecciona una categoría');
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isRegisterMode) {
        await _authService.registerMerchant(
          businessName: _businessNameCtrl.text.trim(),
          ruc: _rucCtrl.text.trim(),
          ownerEmail: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          categoryId: _selectedCategoryId!,
        );
      } else {
        await _authService.loginMerchant(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      }
      if (mounted) context.go('/business');
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'deuna!',
                      style: TextStyle(
                        color: Color(0xFF4A1587),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A9E8F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Negocios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode ? 'Registra tu negocio' : 'Bienvenido',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRegisterMode
                      ? 'Ingresa los datos de tu negocio'
                      : 'Accede al panel de tu negocio',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 32),

                if (_isRegisterMode) ...[
                  _buildField(
                    controller: _businessNameCtrl,
                    label: 'Nombre del negocio',
                    hint: 'Ej. Tienda Don Pepe',
                    icon: Icons.storefront_outlined,
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Mínimo 2 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _rucCtrl,
                    label: 'RUC',
                    hint: '1790012345001',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Campo requerido';
                      if (!RegExp(r'^\d{10,13}$').hasMatch(v.trim())) {
                        return '10 a 13 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                ],

                _buildField(
                  controller: _emailCtrl,
                  label: 'Email del propietario',
                  hint: 'negocio@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _passwordCtrl,
                  label: 'Contraseña',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (_isRegisterMode && v.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A9E8F),
                      disabledBackgroundColor: const Color(0xFF0A9E8F).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isRegisterMode ? 'Registrar negocio' : 'Ingresar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                        _formKey.currentState?.reset();
                        _selectedCategoryId = null;
                      });
                      if (_isRegisterMode) _loadCategories();
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        children: [
                          TextSpan(
                            text: _isRegisterMode
                                ? '¿Ya tienes cuenta? '
                                : '¿No tienes negocio registrado? ',
                          ),
                          TextSpan(
                            text: _isRegisterMode ? 'Inicia sesión' : 'Regístrate',
                            style: const TextStyle(
                              color: Color(0xFF0A9E8F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_loadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Categoría del negocio',
        prefixIcon: const Icon(Icons.category_outlined, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A9E8F), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      hint: const Text('Seleccionar categoría'),
      items: _categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat['id'].toString(),
          child: Text(cat['name']?.toString() ?? cat['id'].toString()),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedCategoryId = v),
      validator: (_) => _isRegisterMode && _selectedCategoryId == null
          ? 'Selecciona una categoría'
          : null,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A9E8F), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
