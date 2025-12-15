import 'package:table_calendar/table_calendar.dart';
import '../../models/device_model.dart';

class AddItemService {
  bool isDateBookable(Device device, DateTime date) {
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }

    final maxDate =
        DateTime.now().add(Duration(days: device.maxRentalDays));
    if (date.isAfter(maxDate)) {
      return false;
    }

    if (device.bookedSlots.any((d) => isSameDay(d, date))) {
      return false;
    }

    return true;
  }

  DateTime getNextAvailableDate(Device device, DateTime fromDate) {
    DateTime current = fromDate;
    while (!isDateBookable(device, current)) {
      current = current.add(const Duration(days: 1));
    }
    return current;
  }
}
