import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_ordering/src/features/menu/data/repositories/menu_repository.dart';
import 'package:web_ordering/src/features/menu/domain/models/category.dart';
import 'package:web_ordering/src/features/menu/domain/models/department.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';

part 'master_event.dart';
part 'master_state.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  final MenuRepository _repository;

  MasterBloc(this._repository) : super(MasterInitial()) {
    on<FetchDepartments>(_onFetchDepartments);
    on<FetchMasterData>(_onFetchMasterData);
  }

  Future<void> _onFetchDepartments(
    FetchDepartments event,
    Emitter<MasterState> emit,
  ) async {
    emit(MasterLoading());
    try {
      final departments = await _repository.fetchDepartments(event.branchId);
      emit(MasterLoaded(branchId: event.branchId, departments: departments));
    } catch (e) {
      emit(MasterError(e.toString()));
    }
  }

  Future<void> _onFetchMasterData(
    FetchMasterData event,
    Emitter<MasterState> emit,
  ) async {
    // Preserve departments visible while menu loads
    final currentDepts = state is MasterLoaded
        ? (state as MasterLoaded).departments
        : state is MasterMenuLoading
            ? (state as MasterMenuLoading).departments
            : <DepartmentModel>[];

    emit(
      MasterMenuLoading(branchId: event.branchId, departments: currentDepts),
    );
    try {
      final results = await Future.wait([
        _repository.fetchCategories(event.branchId, event.departmentId),
        _repository.fetchItems(event.branchId, event.departmentId),
      ]);
      emit(
        MasterLoaded(
          branchId: event.branchId,
          departments: currentDepts,
          categories: results[0] as List<CategoryModel>,
          items: results[1] as List<ItemModel>,
        ),
      );
    } catch (e) {
      emit(MasterError(e.toString()));
    }
  }
}
