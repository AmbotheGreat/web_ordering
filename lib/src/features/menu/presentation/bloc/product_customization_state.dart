part of 'product_customization_bloc.dart';

abstract class ProductCustomizationState extends Equatable {
  const ProductCustomizationState();

  @override
  List<Object?> get props => [];
}

class ProductCustomizationInitial extends ProductCustomizationState {}

class ProductCustomizationLoading extends ProductCustomizationState {}

class ProductCustomizationLoaded extends ProductCustomizationState {
  final List<ProductCustomizationModel> customizations;

  const ProductCustomizationLoaded(this.customizations);

  @override
  List<Object?> get props => [customizations];
}

class ProductCustomizationError extends ProductCustomizationState {
  final String message;

  const ProductCustomizationError(this.message);

  @override
  List<Object?> get props => [message];
}
