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
          const Text(
            'Sona',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: const Text(
                """
“Sona" significa "mujer" en tsáfiqui, un nombre que refleja nuestra misión de empoderar a todas las mujeres. Sona App es una herramienta pensada especialmente para ti, con el objetivo de ofrecerte apoyo y recursos enfocados en tu salud, tu bienestar y tu educación.
Aquí encontrarás:
Calendario Menstrual: Lleva un registro preciso de tu ciclo menstrual, para que puedas entender mejor tu cuerpo y anticipar los cambios que experimentas cada mes. La app te proporciona alertas sobre tus días fértiles, la ovulación y el inicio de tu período, ayudándote a cuidar tu salud.
Contenido Didáctico: Accede a una amplia variedad de artículos, videos y recursos educativos sobre salud femenina, sexualidad, autoestima, derechos y más. Aquí encontrarás información confiable para empoderarte, tomar decisiones informadas y cuidar de ti misma.
Sona App es mucho más que una simple aplicación: es un espacio para que cada mujer encuentre el conocimiento y el acompañamiento necesario para vivir de manera plena y saludable. Porque entendemos que tu bienestar es lo más importante, te brindamos herramientas que te apoyen en cada etapa de tu vida.
""",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
