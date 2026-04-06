import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/home/presentation/widgets/branch_card.dart';
import 'package:web_ordering/src/features/menu/domain/models/department.dart';
import 'package:web_ordering/src/features/menu/presentation/bloc/master_bloc.dart';

List<DepartmentModel> _departmentsFromState(MasterState state) {
  if (state is MasterLoaded) return state.departments;
  if (state is MasterMenuLoading) return state.departments;
  return const [];
}

/// Header widget for the menu screen containing the dynamic department
/// selector (driven by MasterBloc) and the title row.
class MenuHeader extends StatelessWidget {
  final VoidCallback? onSearchPressed;
  final int? selectedBranchId;
  final void Function(int departmentId)? onBranchSelected;

  const MenuHeader({
    super.key,
    this.onSearchPressed,
    this.selectedBranchId,
    this.onBranchSelected,
  });

  Color get _activeColor => selectedBranchId == 2 ? const Color(0xFF4CAF50) : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      color: AppColors.backgroundWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Dynamic department list from MasterBloc
          SizedBox(
            height: 100,
            child: BlocBuilder<MasterBloc, MasterState>(
              builder: (context, state) {
                if (state is MasterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MasterError) {
                  return Center(
                    child: Text(
                      'Failed to load departments',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                final departments = _departmentsFromState(state);

                if (departments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No departments found',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }

                return Center(
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: departments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dept = departments[index];
                      return BranchCard(
                        name: dept.name,
                        imageUrl: dept.imageUrl,
                        isSelected: selectedBranchId == dept.id,
                        isAvailable: dept.isAvailable,
                        deptId: dept.id,
                        onTap: () => onBranchSelected?.call(dept.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: _activeColor),
                onPressed: () => context.go('/'),
              ),
              const Text(
                'Explore Our Menu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _activeColor, // Change background color based on selected branch
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                icon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onSearchPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
