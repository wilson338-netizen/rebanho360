import 'dart:math';

class GeradorPG {

  static Map gerar() {

    List pensamentos = [

      "Deus costuma trabalhar nas coisas simples da vida.",
      "Grandes mudanças começam com pequenas decisões.",
      "A fé cresce quando caminhamos juntos.",
      "Relacionamentos são ferramentas de Deus para nos transformar.",
      "Às vezes Deus fala no silêncio das conversas simples."

    ];

    List perguntas = [

      "O que mais te fez sorrir esta semana?",
      "Se você pudesse voltar no tempo para aprender algo antes, o que seria?",
      "Qual lugar te traz paz?",
      "Qual foi um aprendizado recente na sua vida?",
      "Quem te inspirou recentemente?",
      "Se pudesse começar um novo hábito hoje, qual seria?",
      "Qual momento simples te trouxe alegria recentemente?"

    ];

    Random random = Random();

    return {

      "pensamento": pensamentos[random.nextInt(pensamentos.length)],

      "q1": perguntas[random.nextInt(perguntas.length)],

      "q2": perguntas[random.nextInt(perguntas.length)],

      "q3": perguntas[random.nextInt(perguntas.length)],

    };

  }

}
