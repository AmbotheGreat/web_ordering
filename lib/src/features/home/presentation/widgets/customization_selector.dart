import 'package:flutter/material.dart';
import 'package:web_ordering/src/core/theme/app_colors.dart';
import 'package:web_ordering/src/features/menu/domain/models/product_customization.dart';

/// Interactive customization selector widget
class CustomizationSelector extends StatefulWidget {
  final ProductCustomizationModel customization;
  final Function(List<int> selectedOptionIds) onSelectionChanged;
  final bool hasError;

  const CustomizationSelector({
    super.key,
    required this.customization,
    required this.onSelectionChanged,
    this.hasError = false,
  });

  @override
  State<CustomizationSelector> createState() => _CustomizationSelectorState();
}

class _CustomizationSelectorState extends State<CustomizationSelector> {
  final List<int> _selectedOptions = [];

  void _toggleOption(int optionId) {
    setState(() {
      if (widget.customization.selectionType == 0) {
        // Single select - toggle off if already selected
        if (_selectedOptions.contains(optionId)) {
          _selectedOptions.clear();
        } else {
          _selectedOptions.clear();
          _selectedOptions.add(optionId);
        }
      } else if (widget.customization.selectionType == 1) {
        // Multi select - toggle
        if (_selectedOptions.contains(optionId)) {
          _selectedOptions.remove(optionId);
        } else {
          if (_selectedOptions.length < widget.customization.maxSelect) {
            _selectedOptions.add(optionId);
          }
        }
      } else if (widget.customization.selectionType == 2) {
        // Multi select repeated - increment
        if (_selectedOptions.length < widget.customization.maxSelect) {
          _selectedOptions.add(optionId);
        } else {
          // Reset to 0 when pressing again while at max capacity
          if (_selectedOptions.contains(optionId)) {
            _selectedOptions.removeWhere((id) => id == optionId);
          }
        }
      }
      widget.onSelectionChanged(_selectedOptions.toList());
    });
  }

  void _decrementOption(int optionId) {
    setState(() {
      _selectedOptions.remove(optionId);
      widget.onSelectionChanged(_selectedOptions.toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSingleSelect = widget.customization.selectionType == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hasError ? AppColors.error : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: widget.hasError
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with requirement hint
            Row(
              children: [
                Text(
                  widget.customization.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.customization.isRequired && isSingleSelect)
                  Text(
                    '* Pick 1',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.hasError
                          ? AppColors.error
                          : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                      fontWeight: widget.hasError
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  )
                else if (!isSingleSelect && widget.customization.maxSelect > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Select up to ${widget.customization.maxSelect}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),

                if (!widget.customization.isRequired && !isSingleSelect)
                  Text(
                    '*Optional',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.hasError
                          ? AppColors.error
                          : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                      fontWeight: widget.hasError
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                if (!widget.customization.isRequired && isSingleSelect)
                  Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.hasError
                          ? AppColors.error
                          : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                      fontWeight: widget.hasError
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                // Info Icon if description exists
                if (widget.customization.description != null &&
                    widget.customization.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                      message: widget.customization.description!,
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Options Wrap Layout
            if (widget.customization.options.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No options available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: widget.customization.options.map((option) {
                  final count = _selectedOptions
                      .where((id) => id == option.id)
                      .length;
                  final isSelected = count > 0;
                  final isAtMax =
                      _selectedOptions.length >= widget.customization.maxSelect;

                  bool canTapMain = true;
                  if (widget.customization.selectionType == 0) {
                    canTapMain = true;
                  } else if (widget.customization.selectionType == 1) {
                    canTapMain = isSelected || !isAtMax;
                  } else if (widget.customization.selectionType == 2) {
                    canTapMain = isSelected || !isAtMax;
                  }

                  return InkWell(
                    onTap: canTapMain ? () => _toggleOption(option.id) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.customization.selectionType == 2 &&
                              count > 0) ...[
                            GestureDetector(
                              onTap: () => _decrementOption(option.id),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${count}x',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            (widget.customization.name.toLowerCase().contains(
                                          'sugar',
                                        ) ||
                                        widget.customization.name
                                            .toLowerCase()
                                            .contains('sweetness')) &&
                                    double.tryParse(option.name) != null
                                ? '${option.name}%'
                                : option.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (option.price != null && option.price! > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(+₱${option.price!.toStringAsFixed(0)})',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
