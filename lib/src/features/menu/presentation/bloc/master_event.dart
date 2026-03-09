part of 'master_bloc.dart';

abstract class MasterEvent extends Equatable {
  const MasterEvent();

  @override
  List<Object> get props => [];
}

/// Loads the departments list for the given branch on startup.
class FetchDepartments extends MasterEvent {
  final int branchId;

  const FetchDepartments({required this.branchId});

  @override
  List<Object> get props => [branchId];
}

/// Loads categories + items filtered by both branchId and departmentId.
class FetchMasterData extends MasterEvent {
  final int branchId;
  final int departmentId;

  const FetchMasterData({required this.branchId, required this.departmentId});

  @override
  List<Object> get props => [branchId, departmentId];
}
