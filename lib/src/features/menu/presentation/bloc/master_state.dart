part of 'master_bloc.dart';

abstract class MasterState extends Equatable {
  const MasterState();

  @override
  List<Object> get props => [];
}

class MasterInitial extends MasterState {}

class MasterLoading extends MasterState {}

class MasterLoaded extends MasterState {
  final List<CategoryModel> categories;
  final List<ItemModel> items;

  const MasterLoaded({required this.categories, required this.items});

  @override
  List<Object> get props => [categories, items];
}

class MasterError extends MasterState {
  final String message;

  const MasterError(this.message);

  @override
  List<Object> get props => [message];
}
