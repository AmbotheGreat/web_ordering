part of 'branch_bloc.dart';

abstract class BranchEvent extends Equatable {
  const BranchEvent();

  @override
  List<Object> get props => [];
}

class FetchBranches extends BranchEvent {
  final int branchId;

  const FetchBranches({required this.branchId});

  @override
  List<Object> get props => [branchId];
}
