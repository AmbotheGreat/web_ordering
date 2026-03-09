part of 'master_bloc.dart';

abstract class MasterState extends Equatable {
  const MasterState();

  @override
  List<Object> get props => [];
}

class MasterInitial extends MasterState {}

/// Shown while departments are being fetched on startup.
class MasterLoading extends MasterState {}

/// Shown while categories/items are loading — departments already available
/// so the header can still display the department selector.
class MasterMenuLoading extends MasterState {
  final int branchId;
  final List<DepartmentModel> departments;

  const MasterMenuLoading({required this.branchId, required this.departments});

  @override
  List<Object> get props => [branchId, departments];
}

class MasterLoaded extends MasterState {
  final int branchId;
  final List<DepartmentModel> departments;
  final List<CategoryModel> categories;
  final List<ItemModel> items;

  const MasterLoaded({
    required this.branchId,
    required this.departments,
    this.categories = const [],
    this.items = const [],
  });

  @override
  List<Object> get props => [branchId, departments, categories, items];
}

class MasterError extends MasterState {
  final String message;

  const MasterError(this.message);

  @override
  List<Object> get props => [message];
}
