part of 'master_bloc.dart';

abstract class MasterEvent extends Equatable {
  const MasterEvent();

  @override
  List<Object> get props => [];
}

class FetchMasterData extends MasterEvent {
  final int branchId;

  const FetchMasterData({required this.branchId});

  @override
  List<Object> get props => [branchId];
}
