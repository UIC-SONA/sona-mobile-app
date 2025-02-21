import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  //
  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      padding: 20,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Warmi PL',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery
                        .of(context)
                        .size
                        .height * 0.24,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    """
“Warmi" significa "mujer" en quechua, un nombre que refleja nuestra misión de empoderar a todas las mujeres. Warmi PL es una herramienta pensada especialmente para ti, con el objetivo de ofrecerte apoyo y recursos enfocados en tu salud, tu bienestar y tu educación.
\nAquí encontrarás:\n
Calendario Menstrual: Lleva un registro preciso de tu ciclo menstrual, para que puedas entender mejor tu cuerpo y anticipar los cambios que experimentas cada mes. La app te proporciona alertas sobre tus días fértiles, la ovulación y el inicio de tu período, ayudándote a cuidar tu salud.\n
Contenido Didáctico: Accede a una amplia variedad de artículos, videos y recursos educativos sobre salud femenina, sexualidad, autoestima, derechos y más. Aquí encontrarás información confiable para empoderarte, tomar decisiones informadas y cuidar de ti misma.\n
Sona es mucho más que una simple aplicación: es un espacio para que cada mujer encuentre el conocimiento y el acompañamiento necesario para vivir de manera plena y saludable. Porque entendemos que tu bienestar es lo más importante, te brindamos herramientas que te apoyen en cada etapa de tu vida.
""",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
