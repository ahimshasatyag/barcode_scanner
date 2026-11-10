import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const greenColor = Color(0xFF2E7D32);

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: 1,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar Bulat
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: profile.isActive ? greenColor : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Detail Nama & Info Pekerjaan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.username} • ${profile.idKaryawan ?? "Staf"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppStatusBadge(
                      status: profile.role,
                      color: colorScheme.primary,
                      isDense: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Metadata Lokasi & Shift Gudang
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Departemen',
            value: profile.department,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.store_mall_directory_outlined,
            label: 'Lokasi Gudang',
            value: profile.warehouseLocation,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Jadwal Shift',
            value: profile.shift,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

