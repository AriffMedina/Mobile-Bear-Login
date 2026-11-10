import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 


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

  //4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

   // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Acción del botón
  void _onLogin(){
    //Recortar espacios en blanco accidentales
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    //Recalcular errores
    final emailTypedError = isValidEmail(email) ? null : 'Email inválido';
    final passTypedError = isValidPassword(pass) ? null : 'Contraseña inválida';

    //4.5 Para mostrar el cambio
    setState(() {
      emailError = emailTypedError;
      passError = passTypedError;
    });

    //4.6 Cerrar el teclado y oso neutro
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.7 Activar triggers
    if (emailTypedError == null && passTypedError == null){
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
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
                      errorText: emailError,
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
                      errorText: passError,
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
                  color: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  onPressed: _onLogin,
                  child: Text(
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