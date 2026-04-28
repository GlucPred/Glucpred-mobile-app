import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glucpred/features/alerts/presentation/screens/alert_ranges_screen.dart';
import 'package:glucpred/features/auth/presentation/screens/change_password_screen.dart';
import 'package:glucpred/features/auth/presentation/screens/login_selection_screen.dart';
import 'package:glucpred/features/settings/presentation/viewmodels/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settings, _) => Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Alertas y Notificaciones ─────────────────────────────────
            _buildSectionTitle(context, 'Alertas y Notificaciones'),
            const SizedBox(height: 12),

            _buildNavigationCard(
              context,
              icon: Icons.tune,
              title: 'Rangos de alerta',
              subtitle: 'Configurar valores mínimos y máximos.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AlertRangesScreen()),
              ),
            ),
            const SizedBox(height: 8),

            _buildSwitchCard(
              context,
              icon: Icons.volume_up,
              title: 'Sonidos',
              subtitle: 'Activar alertas sonoras.',
              value: settings.soundEnabled,
              onChanged: settings.setSoundEnabled,
            ),
            const SizedBox(height: 8),

            _buildSwitchCard(
              context,
              icon: Icons.vibration,
              title: 'Vibración',
              subtitle: 'Activar vibración en alertas.',
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
            const SizedBox(height: 8),

            _buildSwitchCard(
              context,
              icon: Icons.alarm,
              title: 'Recordatorios',
              subtitle: 'Notificación diaria a las 9:00 AM para medir glucosa.',
              value: settings.remindersEnabled,
              onChanged: settings.setRemindersEnabled,
            ),
            const SizedBox(height: 24),

            // ── Seguridad ────────────────────────────────────────────────
            _buildSectionTitle(context, 'Seguridad'),
            const SizedBox(height: 12),

            _buildNavigationCard(
              context,
              icon: Icons.lock,
              title: 'Cambiar contraseña',
              subtitle: 'Actualizar credenciales de acceso.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()),
              ),
            ),
            const SizedBox(height: 24),

            // ── Apariencia ───────────────────────────────────────────────
            _buildSectionTitle(context, 'Apariencia'),
            const SizedBox(height: 12),

            _buildSwitchCard(
              context,
              icon: Icons.dark_mode,
              title: 'Modo oscuro',
              subtitle: 'Cambiar tema de la aplicación.',
              value: settings.isDarkMode,
              onChanged: (value) {
                settings.setDarkMode(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Modo oscuro activado' : 'Modo claro activado',
                    ),
                    backgroundColor: const Color(0xFF337536),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Cerrar sesión ────────────────────────────────────────────
            _buildSectionTitle(context, 'Sesión'),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC72331),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color:
              isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const iconColor = Color(0xFF0073E6);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _iconBox(icon, iconColor, isDark),
              const SizedBox(width: 16),
              Expanded(child: _labelColumn(title, subtitle, isDark)),
              Icon(
                Icons.arrow_forward_ios,
                color: isDark
                    ? const Color(0xFF4A9EFF)
                    : const Color(0xFF0073E6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const iconColor = Color(0xFF0073E6);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _iconBox(icon, iconColor, isDark),
            const SizedBox(width: 16),
            Expanded(child: _labelColumn(title, subtitle, isDark)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF0073E6),
              activeTrackColor: const Color(0xFF0073E6).withAlpha(80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 51 : 26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _labelColumn(String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color:
                isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded,
                  size: 48, color: Color(0xFFC72331)),
              const SizedBox(height: 16),
              Text(
                '¿Estás seguro de cerrar sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Al aceptar se cerrará la sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6C7C93)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white70
                            : const Color(0xFF6C7C93),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFFE0E6EB),
                        ),
                      ),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const LoginSelectionScreen()),
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC72331),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Cerrar sesión',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
