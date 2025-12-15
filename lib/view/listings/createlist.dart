import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinjamtech_app/view_model/listing_viewmodel.dart';

class CreateList extends StatelessWidget {
  const CreateList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: Center(
        child: vm.isPublishing
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () {
                  vm.publishListing(
                    name: 'Macbook',
                    brand: 'Apple',
                    price: 20,
                    description: 'Good condition',
                    specification: 'M2, 16GB',
                    location: vm.locationMessage,
                  );
                },
                child: const Text('Publish'),
              ),
      ),
    );
  }
}
