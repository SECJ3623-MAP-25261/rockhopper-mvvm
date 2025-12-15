import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/device_model.dart';
import 'package:pinjamtech_app/view_model/rentee_viewmodel.dart';
import '../../listings/createlist.dart';
import '../../listings/edit_listing.dart';
import '../../listings/delete_listing.dart';


class RenteeHome extends StatelessWidget {
  const RenteeHome({super.key});

  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RenteeHomeViewModel(),
      child: const _RenteeHomeBody(),
    );
  }
}

class _RenteeHomeBody extends StatelessWidget {
  const _RenteeHomeBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RenteeHomeViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: RenteeHome.primaryGreen,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateList()),
          ).then((device) {
            if (device is Device) {
              vm.addDevice(device);
              vm.loadDevices();
            }
          });
        },
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _title(),
                  _dashboardTitle(),
                  _deviceGrid(vm, context),
                ],
              ),
      ),
    );
  }

  Widget _title() {
    return Center(
      child: Text(
        'PinjamTech',
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: RenteeHome.primaryGreen,
        ),
      ),
    );
  }

  Widget _dashboardTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Rentee Dashboard',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: RenteeHome.primaryGreen,
        ),
      ),
    );
  }

  Widget _deviceGrid(RenteeHomeViewModel vm, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.devices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final device = vm.devices[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditListing(
                  device: device,
                  bookedSlots: device.bookedSlots,
                ),
              ),
            ).then((updated) {
              if (updated is Device) vm.updateDevice(updated);
            });
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => DeleteListing(device: device),
            ).then((deleted) {
              if (deleted == true) vm.deleteDevice(device);
            });
          },
          child: Card(
            child: Column(
              children: [
                Expanded(
                  child: Image.network(device.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(device.name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RenteeHomeView extends StatelessWidget {
  const RenteeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RenteeHomeViewModel()..loadDevices(),
      child: const _RenteeHomeUI(),
    );
  }
}

class _RenteeHomeUI extends StatelessWidget {
  const _RenteeHomeUI();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RenteeHomeViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.devices.length,
      itemBuilder: (context, index) {
        final Device device = vm.devices[index];
        return ListTile(
          title: Text(device.name),
          subtitle: Text("RM ${device.pricePerDay}/day"),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => vm.deleteDevice(device),
          ),
        );
      },
    );
  }
}
