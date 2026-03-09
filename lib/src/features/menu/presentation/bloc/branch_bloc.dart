import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_ordering/src/features/menu/data/repositories/menu_repository.dart';
import 'package:web_ordering/src/features/menu/domain/models/department.dart';

part 'branch_event.dart';
part 'branch_state.dart';

class BranchBloc extends Bloc<BranchEvent, BranchState> {
  final MenuRepository _repository;

  BranchBloc(this._repository) : super(BranchInitial()) {
    on<FetchBranches>(_onFetchBranches);
  }

  Future<void> _onFetchBranches(
    FetchBranches event,
    Emitter<BranchState> emit,
  ) async {
    emit(BranchLoading());
    try {
      final departments = await _repository.fetchDepartments(event.branchId);
      emit(BranchLoaded(departments: departments));
    } catch (e) {
      emit(BranchError(e.toString()));
    }
  }
}
