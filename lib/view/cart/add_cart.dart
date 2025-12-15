import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/device_model.dart';
import 'package:pinjamtech_app/view_model/cart_viewmodel.dart';

class AddItemView extends StatelessWidget {
  final Device device;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const AddItemView({
    super.key,
    required this.device,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddItemViewModel(
        device,
        start: initialStartDate,
        end: initialEndDate,
      ),
      child: const _AddItemBody(),
    );
  }
}

class _AddItemBody extends StatelessWidget {
  const _AddItemBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Rental Dates')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now()
                .add(Duration(days: vm.device.maxRentalDays)),
            focusedDay: vm.focusedDay,
            rangeStartDay: vm.selectedStartDate,
            rangeEndDay: vm.selectedEndDate,
            calendarFormat: vm.calendarFormat,
            rangeSelectionMode: vm.rangeSelectionMode,
            onDaySelected: (day, _) {
              if (!vm.isBookable(day)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Date not available'),
                  ),
                );
                return;
              }
              vm.onDaySelected(day);
            },
          ),

          Text('Total: RM ${vm.totalPrice.toStringAsFixed(2)}'),

          ElevatedButton(
            onPressed: vm.selectedStartDate != null &&
                    vm.selectedEndDate != null
                ? () {
                    Navigator.pop(
                        context, vm.buildCartItem());
                  }
                : null,
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}
