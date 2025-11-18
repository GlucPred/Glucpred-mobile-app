import 'package:flutter/material.dart';
import '../services/alerts_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Todas, 1: Críticas, 2: Recordatorios
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    
    try {
      String typeFilter = 'todas';
      if (_selectedTab == 1) {
        typeFilter = 'critica';
      } else if (_selectedTab == 2) {
        typeFilter = 'recordatorio';
      }
      
      final response = await AlertsService.getAlerts(
        type: typeFilter,
        limit: 50,
      );
      
      setState(() {
        _alerts = List<Map<String, dynamic>>.from(response['alerts'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alertas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF0073E6)),
            onPressed: _alerts.isEmpty ? null : _markAllAsRead,
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Todas', 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildTabButton('Críticas', 1)),
                const SizedBox(width: 8),
                Expanded(child: _buildTabButton('Recordatorios', 2)),
              ],
            ),
          ),
          
          // Lista de alertas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _alerts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAlerts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) {
                            return _buildAlertCard(_alerts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateReminderDialog,
        backgroundColor: const Color(0xFF0073E6),
        child: const Icon(Icons.add),
        tooltip: 'Crear recordatorio',
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await AlertsService.markAllAsRead();
      await _loadAlerts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas las alertas marcadas como leídas')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCreateReminderDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      try {
        await AlertsService.createReminder(
          title: titleController.text,
          message: messageController.text,
        );
        await _loadAlerts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recordatorio creado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
          _loadAlerts(); // Recargar al cambiar de tab
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? const Color(0xFF0073E6) 
            : (isDark ? const Color(0xFF1A1F3A) : Colors.white),
        foregroundColor: isSelected 
            ? Colors.white 
            : (isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93)),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected 
                ? const Color(0xFF0073E6) 
                : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
            width: 1,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertId = alert['id'];
    final title = alert['titulo'] ?? 'Sin título';
    final message = alert['mensaje'] ?? '';
    final createdAt = alert['created_at'] ?? '';
    final isRead = alert['is_read'] ?? false;
    final severity = alert['severidad'] ?? 'info';
    final type = alert['tipo'] ?? 'critica';
    
    final severityColor = AlertsService.getColorBySeverity(severity);
    final typeIcon = AlertsService.getIconByType(type);
    final timeAgo = AlertsService.getTimeAgo(createdAt);
    
    return Dismissible(
      key: Key('alert_$alertId'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar alerta'),
            content: const Text('¿Deseas eliminar esta alerta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          await AlertsService.dismissAlert(alertId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alerta eliminada')),
            );
          }
        } catch (e) {
          await _loadAlerts(); // Recargar si falla
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar: $e')),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        color: isRead ? null : (isDark ? const Color(0xFF1E2742) : const Color(0xFFF0F7FF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isRead ? BorderSide.none : BorderSide(
            color: severityColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _markAlertAsRead(alertId, isRead),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      typeIcon,
                      color: severityColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: severityColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        severity == 'critico' ? 'Crítico' : 
                        severity == 'advertencia' ? 'Advertencia' : 'Info',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAlertAsRead(int alertId, bool isCurrentlyRead) async {
    if (isCurrentlyRead) return;
    
    try {
      await AlertsService.markAsRead(alertId);
      await _loadAlerts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String message = 'No hay alertas';
    
    if (_selectedTab == 1) {
      message = 'No hay alertas críticas';
    } else if (_selectedTab == 2) {
      message = 'No hay recordatorios';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == 2 ? Icons.notifications_none : Icons.check_circle_outline,
            size: 64,
            color: const Color(0xFF0073E6),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
          ),
        ],
      ),
    );
  }
}
