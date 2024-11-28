import 'package:flutter/material.dart';

class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Denegado'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'No tienes permisos para acceder a esta página.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the action when the user is denied access
                  Navigator.pop(context); // Go back to the previous page
                },
                child: const Text('Volver a la página anterior'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
