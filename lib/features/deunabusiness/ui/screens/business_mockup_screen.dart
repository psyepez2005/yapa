import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/services/merchant_service.dart';
import 'package:yapa/core/storage/token_storage.dart';
import '../widgets/business_app_bar.dart';
import '../widgets/business_tab_bar.dart';
import '../widgets/cobrar_view.dart';
import '../widgets/qr_view.dart';
import '../widgets/gestionar_view.dart';
import 'business_yapa_tracking_screen.dart';
import 'create_yapa_screen.dart';

export '../widgets/cobrar_view.dart' show CobrarMode;

class BusinessMockupScreen extends StatefulWidget {
  const BusinessMockupScreen({super.key});

  @override
  State<BusinessMockupScreen> createState() => _BusinessMockupScreenState();
}

class _BusinessMockupScreenState extends State<BusinessMockupScreen> {
  int _currentTab = 0;
  String _amount = '';
  bool _showQR = false;
  CobrarMode _cobrarMode = CobrarMode.qr;
  String? _merchantId;
  MerchantStats? _stats;
  List<MerchantCoupon> _coupons = [];
  bool _loadingStats = false;
  int _navIndex = 0;
  bool _loyaltyEnabled = true;
  bool _togglingLoyalty = false;

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
    _loadStats();
  }

  Future<void> _loadMerchantId() async {
    final id = await TokenStorage.getMerchantId();
    if (mounted) setState(() => _merchantId = id);
  }

  Future<void> _loadStats() async {
    if (_loadingStats) return;
    setState(() => _loadingStats = true);
    try {
      final service = MerchantService();
      final results = await Future.wait([
        service.fetchStats(),
        service.fetchCoupons(),
      ]);
      if (mounted) {
        final stats = results[0] as MerchantStats;
        setState(() {
          _stats = stats;
          _coupons = results[1] as List<MerchantCoupon>;
          _loyaltyEnabled = stats.loyaltyEnabled;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _toggleLoyalty(bool enabled) async {
    if (_togglingLoyalty) return;
    setState(() {
      _togglingLoyalty = true;
      _loyaltyEnabled = enabled;
    });
    try {
      await MerchantService().toggleLoyalty(enabled: enabled);
    } on MerchantException catch (e) {
      if (mounted) {
        setState(() => _loyaltyEnabled = !enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingLoyalty = false);
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearAll();
    if (mounted) context.go('/');
  }

  void _showTopUpModal() {
    String amount = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Recargar Saldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Ingresa el monto a recargar (máx. \$10,000)', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4A1587), width: 2),
                  ),
                ),
                onChanged: (v) => setModal(() => amount = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A1587),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final parsed = double.tryParse(amount.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return;
                    Navigator.pop(ctx);
                    try {
                      await MerchantService().topUpFund(parsed);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saldo recargado: \$${parsed.toStringAsFixed(2)}'),
                            backgroundColor: const Color(0xFF0A9E8F),
                          ),
                        );
                        _loadStats();
                      }
                    } on MerchantException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Recargar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onKeypadTap(String key) {
    setState(() {
      if (key == 'delete') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        _amount += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BusinessAppBar(
        merchantName: _stats?.merchantName ?? '',
        onLogout: _logout,
      ),
      body: Column(
        children: [
          BusinessTabBar(
            currentTab: _currentTab,
            onTabChanged: (tab) {
              setState(() {
                _currentTab = tab;
                if (tab == 0) {
                  _showQR = false;
                  _cobrarMode = CobrarMode.qr;
                }
              });
              if (tab == 1 && _stats == null) _loadStats();
            },
          ),
          Expanded(
            child: _currentTab == 0
                ? (_showQR
                    ? QRView(
                        amount: _amount,
                        merchantId: _merchantId,
                        merchantName: _stats?.merchantName,
                        continueLabel: _cobrarMode == CobrarMode.manual
                            ? 'Nuevo Cobro'
                            : 'Continuar para Cobrar',
                        onContinue: () => setState(() {
                          _showQR = false;
                          _amount = '';
                          _cobrarMode = CobrarMode.qr;
                        }),
                      )
                    : CobrarView(
                        amount: _amount,
                        mode: _cobrarMode,
                        onKeyTap: _onKeypadTap,
                        onModeChanged: (newMode) {
                          setState(() {
                            _cobrarMode = newMode;
                            if (newMode == CobrarMode.manual) {
                              _showQR = true;
                            }
                          });
                        },
                        onContinue: () => setState(() {
                          _showQR = true;
                        }),
                      ))
                : GestionarView(
                    stats: _stats,
                    coupons: _coupons,
                    loadingStats: _loadingStats,
                    loyaltyEnabled: _loyaltyEnabled,
                    togglingLoyalty: _togglingLoyalty,
                    onRefresh: _loadStats,
                    onTopUp: _showTopUpModal,
                    onToggleLoyalty: _toggleLoyalty,
                    onCreateCoupon: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const CreateYapaScreen(),
                        ),
                      );
                      if (created == true) _loadStats();
                    },
                    onNavigateToYapa: () {
                      setState(() => _navIndex = 2);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BusinessYapaTrackingScreen(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => const BusinessYapaTrackingScreen(),
                  ),
                )
                .then((_) => setState(() => _navIndex = 0));
          } else if (index == 3) {
            TokenStorage.clearAll().then((_) {
              context.go('/');
            });
          } else {
            setState(() {
              _navIndex = index;
              if (index == 0) {
                _currentTab = 0;
                _showQR = false;
                _cobrarMode = CobrarMode.qr;
              } else if (index == 1) {
                _currentTab = 1;
                if (_stats == null) _loadStats();
              }
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Mi Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yapa'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}
