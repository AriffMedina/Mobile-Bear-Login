import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1
//5.1 Firebase Auth y pantalla del herpetario
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_rive_animation/screens/reptiles_screen.dart';


class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  //1.1 Maquina de estados / Cerebro de la animación
  StateMachineController? _controller;
  //StateMachineInput
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  //3.2 Timer para recorrer el recorrido de la mirada
  Timer? _typingDebounce;

  //2.1 Crear varibales para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 Controlller para manipular lo que escribe el usuario
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //5.2 Estado de carga mientras Firebase responde
  bool _isLoading = false;

  //6.1 OWASP: un solo mensaje para cualquier fallo de login. Decir qué campo
  // falló revelaría si el correo existe (enumeración de cuentas).
  static const _invalidCredentials =
      'Credenciales inválidas. Verifica tu correo y contraseña.';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  //4.4 Acción del botón
  //5.3 Ahora es asíncrono porque espera a Firebase
  Future<void> _onLogin() async {
    //Recortar espacios en blanco accidentales
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    //4.6 Cerrar el teclado y oso neutro
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //6.2 Solo se valida que no estén vacíos; las reglas viven en el registro
    if (email.isEmpty || pass.isEmpty){
      _trigFail?.fire();
      _showMessage('Ingresa tu correo y contraseña.');
      return;
    }

    //5.4 Mostrar carga
    setState(() => _isLoading = true);

    try {
      //5.5 Validar credenciales contra Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      //5.6 Éxito: el oso celebra antes de navegar
      if (!mounted) return;
      setState(() => _isLoading = false);
      _trigSuccess?.fire();
      await Future.delayed(const Duration(seconds: 2));

      //5.7 Navegar a productos sin poder volver al login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReptilesScreen()),
      );
    } on FirebaseAuthException catch (e) {
      //5.8 Credenciales no válidas: aviso general, sin marcar un campo específico
      debugPrint('FirebaseAuth error: ${e.code}');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _trigFail?.fire();
      //6.3 Sin red no es un problema de credenciales, y no revela nada de la cuenta
      _showMessage(e.code == 'network-request-failed'
          ? 'Sin conexión. Revisa tu internet e inténtalo de nuevo.'
          : _invalidCredentials);
    }
  }

  //que es focusnode y ciclo de vida de un widget
  //2.2 Crear los oyentes (listeners)
  @override
  void initState() {
    
    super.initState();
    _emailFocus.addListener((){
      if (_emailFocus.hasFocus){
        if (_isHandsUp != null){
          _isHandsUp?.change(false);
          //3.3 Mirada neutral
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocus.addListener((){
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Obtiene el tamaño de la pantalla
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child:  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: 200,
                  child: RiveAnimation.asset('assets/login-bear-animation.riv', 
                    stateMachines: ['Login Machine'],
                    //1.2 Vincular la animación
                    onInit: (artboard){
                      _controller = StateMachineController.fromArtboard(artboard, 'Login Machine');

                      //1.3 Verificar que inció bien
                      if (_controller == null) return;
                      //Agregar el controlador al escenario
                      artboard.addController(_controller!);
                      //1.4 Vincular las variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                      
                    },
                  ),
                ), 
                  
                  //Para separar elementos
                  SizedBox(height: 10),
                  //Email
                  TextField(
                    //4.8 Vincular el controller
                    controller: emailCtrl,            
                    //2.3 Asignar el focus Textfield
                    focusNode: _emailFocus,
                    onChanged: (value){
                      //1.5 Vincular a campo de texto
                      if(_isHandsUp != null){
                        //No tapes los ojos al ver el email
                      //  _isHandsUp!.change(false);
                      }

                      //Si isChecking no es null
                      if(_isChecking == null) return;
                      //Activa el modo chismoso
                      _isChecking!.change(true);
                      //3.4 Implementar recorrido de mirada
                      //Ajuste de límites del 0 a 100
                      //80 medida de calibración. Clamp es un rango (abrazadera)
                      final look = (value.length / 80.0 * 100.0).clamp(
                        0.0, 
                        100.0
                      );
                      _numLook?.value = look;

                      //3.5 Debounce: si vuelve a teclear, reinicia el contador
                      _typingDebounce?.cancel();
                      //Crear nuevo timer
                      _typingDebounce = Timer(const Duration(seconds: 3), (){
                        //Si se cierra la pantalla, termina la ejecución
                        if (!mounted) return;
                        //Mirada neutra después de los 3 segundos
                        _isChecking?.change(false);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        //Para redondear los bordes
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                  //Contraseña
        
                  const SizedBox(height: 10),
        
                  TextField(
                    //4.9 Vincular el controller
                    controller: passCtrl,            
                    //2.3 Asignar el focus Textfield
                    focusNode: _passwordFocus,
                    onChanged: (value){
                      //1.5 Vincular a campo de texto
                      if(_isHandsUp != null){
                        //No actives el modo chismoso en contraseña
                        //_isChecking!.change(false);
                      }

                      //Si isHandsUp no es null
                      if(_isHandsUp == null) return;
                      //Tapa los ojos
                      _isHandsUp!.change(true);
                    },
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }, 
                        icon: Icon(
                          //If ternario
                          _isObscure ? Icons.visibility : Icons.visibility_off
                        ),
                      ),
                      border: OutlineInputBorder(
                        //Para redondear los bordes
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenSize.width,
                  child: const Text("Contraseña olvidada?", 
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline), 
                  )
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  //Toma todo el ancho posible
                  minWidth: screenSize.width,
                  height: 50,
                  color: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  //5.9 Deshabilitado y con spinner mientras carga
                  onPressed: _isLoading ? null : _onLogin,
                  disabledColor: Theme.of(context).colorScheme.primary,
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenSize.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes una cuenta?"),
                        TextButton(onPressed: (){}, child: Text("Register", style: TextStyle(
                          color: Colors.black, 
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)))
                      ],
                    )
                  )
              ],
            ),
          ),),
      )
    );
  }

  @override
  void dispose() {
    //2.4 Liberar memoria/recurso en los focusNode
    _emailFocus.dispose();
    _passwordFocus.dispose();
    //3.5 Liberar timer
    _typingDebounce?.cancel();
    super.dispose();
  }
}