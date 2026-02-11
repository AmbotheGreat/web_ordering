import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_ordering/src/features/menu/data/repositories/menu_repository.dart';
import 'package:web_ordering/src/features/menu/domain/models/product_customization.dart';

part 'product_customization_event.dart';
part 'product_customization_state.dart';

class ProductCustomizationBloc
    extends Bloc<ProductCustomizationEvent, ProductCustomizationState> {
  final MenuRepository _repository;

  // Cache to store already fetched customizations
  final Map<String, List<ProductCustomizationModel>> _cache = {};

  ProductCustomizationBloc(this._repository)
    : super(ProductCustomizationInitial()) {
    on<FetchProductCustomization>(_onFetchProductCustomization);
  }

  Future<void> _onFetchProductCustomization(
    FetchProductCustomization event,
    Emitter<ProductCustomizationState> emit,
  ) async {
    // Check cache first
    if (_cache.containsKey(event.barcode)) {
      emit(ProductCustomizationLoaded(_cache[event.barcode]!));
      return;
    }

    emit(ProductCustomizationLoading());

    try {
      final customizations = await _repository
          .fetchProductCustomizationByBarcode(event.barcode, event.branchId);

      // Store in cache
      _cache[event.barcode] = customizations;

      emit(ProductCustomizationLoaded(customizations));
    } catch (e) {
      emit(ProductCustomizationError(e.toString()));
    }
  }
}
