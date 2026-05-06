// ==========================================
// 1 IMPORTAÇÕES
// ==========================================

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'cadastro_membro_page.dart';


// ==========================================
// 2 INÍCIO DO APP
// ==========================================

void main() {
  runApp(RebanhoApp());
}


// ==========================================
// 3 APP PRINCIPAL
// ==========================================

class RebanhoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Rebanho360',

      // ==========================================
      // 🔥 TEMA PROFISSIONAL (VISUAL MODERNO)
      // ==========================================
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.grey[100],

        // ================= APPBAR =================
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
        ),

        // ================= CARDS =================
        cardTheme: CardThemeData(
  elevation: 3,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
),
          

        // ================= BOTÕES =================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ================= INPUTS =================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ==========================================
      // 🔥 ROTAS
      // ==========================================
      routes: {
        '/cadastro': (context) => CadastroMembroPage(),
      },

      // ==========================================
      // 🔥 TELA INICIAL
      // ==========================================
      home: LoginPage(),
    );
  }
}
