part of 'product_customization_bloc.dart';

abstract class ProductCustomizationEvent extends Equatable {
  const ProductCustomizationEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductCustomization extends ProductCustomizationEvent {
  final String barcode;
  final int branchId;

  const FetchProductCustomization({
    required this.barcode,
    required this.branchId,
  });

  @override
  List<Object?> get props => [barcode, branchId];
}
