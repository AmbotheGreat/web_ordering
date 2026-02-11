import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_ordering/src/features/menu/data/repositories/menu_repository.dart';
import 'package:web_ordering/src/features/menu/domain/models/category.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';

part 'master_event.dart';
part 'master_state.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  final MenuRepository _repository;

  MasterBloc(this._repository) : super(MasterInitial()) {
    on<FetchMasterData>(_onFetchMasterData);
  }

  Future<void> _onFetchMasterData(
    FetchMasterData event,
    Emitter<MasterState> emit,
  ) async {
    emit(MasterLoading());
    try {
      final categories = await _repository.fetchCategories(event.branchId);
      final items = await _repository.fetchItems(event.branchId);

      emit(MasterLoaded(categories: categories, items: items));
    } catch (e) {
      emit(MasterError(e.toString()));
    }
  }
}
