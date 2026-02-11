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
    // Clear cache to ensure fresh fetch for debugging
    print('🔄 ProductCustomizationBloc initialized, cache cleared');
    _cache.clear();
  }

  Future<void> _onFetchProductCustomization(
    FetchProductCustomization event,
    Emitter<ProductCustomizationState> emit,
  ) async {
    print(
      '🔍 ProductCustomizationBloc: Fetching for barcode: ${event.barcode}',
    );

    // Check cache first
    if (_cache.containsKey(event.barcode)) {
      print('✅ Found in cache for barcode: ${event.barcode}');
      emit(ProductCustomizationLoaded(_cache[event.barcode]!));
      return;
    }

    print('⏳ Loading customizations for barcode: ${event.barcode}');
    emit(ProductCustomizationLoading());

    try {
      print('📡 calling repository.fetchProductCustomizationByBarcode...');
      final customizations = await _repository
          .fetchProductCustomizationByBarcode(event.barcode, event.branchId)
          .timeout(const Duration(seconds: 3)); // Add timeout

      print(
        '✅ Fetched ${customizations.length} customizations for barcode: ${event.barcode}',
      );

      // Store in cache
      _cache[event.barcode] = customizations;

      emit(ProductCustomizationLoaded(customizations));
    } catch (e) {
      print('❌ Error fetching customizations: $e');
      emit(ProductCustomizationError(e.toString()));
    }
  }
}
