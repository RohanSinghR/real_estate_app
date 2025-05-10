import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget child;

  const PageTemplate({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [            Color.fromARGB(255, 10, 7, 6),          Color.fromARGB(255, 10, 7, 6),
              Color.fromARGB(255, 10, 7, 6),
              Color.fromARGB(255, 88, 21, 1),
              Color.fromARGB(255, 133, 37, 2),
              Color.fromARGB(255, 10, 7, 6),
                         Color.fromARGB(255, 10, 7, 6),
                                    Color.fromARGB(255, 10, 7, 6),
                                     Color.fromARGB(255, 10, 7, 6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}
