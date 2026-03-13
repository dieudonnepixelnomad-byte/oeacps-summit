class AboutData {
  final String title;
  final String appDescriptionTitle;
  final String appDescriptionContent;
  final String eventTitle;
  final String eventContent;
  final String oacpsTitle;
  final String oacpsContent;
  final String featuresTitle;
  final List<String> features;
  final String organizationTitle;
  final String organizationContent;
  final String contactTitle;
  final String contactContent;
  final String legalTitle;
  final String legalContent;
  final String versionTitle;
  final String versionContent;

  const AboutData({
    required this.title,
    required this.appDescriptionTitle,
    required this.appDescriptionContent,
    required this.eventTitle,
    required this.eventContent,
    required this.oacpsTitle,
    required this.oacpsContent,
    required this.featuresTitle,
    required this.features,
    required this.organizationTitle,
    required this.organizationContent,
    required this.contactTitle,
    required this.contactContent,
    required this.legalTitle,
    required this.legalContent,
    required this.versionTitle,
    required this.versionContent,
  });

  static const Map<String, AboutData> data = {
    'fr': AboutData(
      title: "À propos",
      appDescriptionTitle: "1. Présentation de l’application",
      appDescriptionContent:
          "L’application officielle du 11ᵉ Sommet des Chefs d’État et de Gouvernement de l’OACPS a été conçue pour permettre aux participants, journalistes et partenaires d’accéder facilement aux informations essentielles de l’événement.\n\nElle centralise le programme officiel, les informations pratiques, les actualités institutionnelles ainsi que les ressources destinées aux médias.\n\nL’objectif de cette application est de faciliter l’accès à l’information et d’offrir une expérience numérique moderne aux participants du Sommet organisé à Malabo, en Guinée équatoriale, du 27 au 29 mars 2026.",
      eventTitle: "2. Présentation de l’événement",
      eventContent:
          "Le Sommet OACPS 2026\n\nLe Sommet des Chefs d’État et de Gouvernement de l’Organisation des États d’Afrique, des Caraïbes et du Pacifique (OACPS) est l’un des événements diplomatiques majeurs réunissant les dirigeants des pays membres.\n\nCe sommet constitue un moment stratégique pour :\n• renforcer la coopération entre les États membres\n• promouvoir le développement durable\n• discuter des grands enjeux mondiaux\n• renforcer les partenariats internationaux\n\nL’édition 2026 se tient à Malabo, capitale de la Guinée équatoriale.",
      oacpsTitle: "3. Présentation de l’organisation (OACPS)",
      oacpsContent:
          "À propos de l’OACPS\n\nL’Organisation des États d’Afrique, des Caraïbes et du Pacifique (OACPS) est une organisation intergouvernementale regroupant 79 pays membres.\n\nSa mission est de :\n• promouvoir la coopération politique et économique\n• soutenir le développement durable\n• renforcer les partenariats internationaux\n• défendre les intérêts communs de ses États membres\n\nL’OACPS joue un rôle important dans les relations internationales et les politiques de développement.\n\nSite officiel : www.oacps.org",
      featuresTitle: "4. Fonctionnalités de l’application",
      features: [
        "Consulter le programme officiel du Sommet",
        "Accéder aux forums et événements",
        "Suivre les actualités et annonces officielles",
        "Accéder à l’espace presse",
        "Obtenir des informations sur les procédures d’accréditation",
      ],
      organizationTitle: "5. Informations sur l’organisation de l’événement",
      organizationContent:
          "Organisation\n\nLe Sommet est organisé sous le haut patronage de la République de Guinée équatoriale, en collaboration avec le Secrétariat de l’OACPS.\n\nLieu principal :\nSipopo Conference Center\nMalabo – Guinée équatoriale",
      contactTitle: "6. Contact",
      contactContent:
          "Secrétariat du Sommet OACPS\nMalabo – Guinée équatoriale\n\nEmail : summit2025@acp.int\nSite officiel : www.oacps.org",
      legalTitle: "7. Informations légales",
      legalContent:
          "© 2026 OACPS – Malabo Summit\nTous droits réservés.\nL’utilisation de cette application est soumise aux politiques de confidentialité et aux conditions d’utilisation de l’organisation.",
      versionTitle: "8. Version de l’application",
      versionContent: "Version : 1.0\nDernière mise à jour : mars 2026",
    ),
    'en': AboutData(
      title: "About",
      appDescriptionTitle: "1. About the Application",
      appDescriptionContent:
          "The official application of the 11th Summit of OACPS Heads of State and Government has been designed to provide participants, journalists, and partners with easy access to essential event information.\n\nIt centralizes the official program, practical information, institutional news, and media resources.\n\nThe goal of this application is to facilitate access to information and offer a modern digital experience to participants of the Summit organized in Malabo, Equatorial Guinea, from March 27 to 29, 2026.",
      eventTitle: "2. About the Event",
      eventContent:
          "The OACPS Summit 2026\n\nThe Summit of Heads of State and Government of the Organisation of African, Caribbean and Pacific States (OACPS) is one of the major diplomatic events bringing together leaders from member countries.\n\nThis summit constitutes a strategic moment to:\n• strengthen cooperation among member states\n• promote sustainable development\n• discuss major global issues\n• strengthen international partnerships\n\nThe 2026 edition is held in Malabo, capital of Equatorial Guinea.",
      oacpsTitle: "3. About the Organization (OACPS)",
      oacpsContent:
          "About the OACPS\n\nThe Organisation of African, Caribbean and Pacific States (OACPS) is an intergovernmental organization comprising 79 member countries.\n\nIts mission is to:\n• promote political and economic cooperation\n• support sustainable development\n• strengthen international partnerships\n• defend the common interests of its member states\n\nThe OACPS plays an important role in international relations and development policies.\n\nOfficial website: www.oacps.org",
      featuresTitle: "4. Application Features",
      features: [
        "Consult the official Summit program",
        "Access forums and events",
        "Follow news and official announcements",
        "Access the press room",
        "Get information on accreditation procedures",
      ],
      organizationTitle: "5. Event Organization Information",
      organizationContent:
          "Organization\n\nThe Summit is organized under the high patronage of the Republic of Equatorial Guinea, in collaboration with the OACPS Secretariat.\n\nMain Venue:\nSipopo Conference Center\nMalabo – Equatorial Guinea",
      contactTitle: "6. Contact",
      contactContent:
          "OACPS Summit Secretariat\nMalabo – Equatorial Guinea\n\nEmail: summit2025@acp.int\nOfficial website: www.oacps.org",
      legalTitle: "7. Legal Information",
      legalContent:
          "© 2026 OACPS – Malabo Summit\nAll rights reserved.\nThe use of this application is subject to the organization's privacy policies and terms of use.",
      versionTitle: "8. Application Version",
      versionContent: "Version: 1.0\nLast updated: March 2026",
    ),
    'es': AboutData(
      title: "Acerca de",
      appDescriptionTitle: "1. Presentación de la aplicación",
      appDescriptionContent:
          "La aplicación oficial de la 11ª Cumbre de Jefes de Estado y de Gobierno de la OEACP ha sido diseñada para permitir a los participantes, periodistas y socios acceder fácilmente a la información esencial del evento.\n\nCentraliza el programa oficial, la información práctica, las noticias institucionales, así como los recursos destinados a los medios de comunicación.\n\nEl objetivo de esta aplicación es facilitar el acceso a la información y ofrecer una experiencia digital moderna a los participantes de la Cumbre organizada en Malabo, Guinea Ecuatorial, del 27 al 29 de marzo de 2026.",
      eventTitle: "2. Presentación del evento",
      eventContent:
          "La Cumbre OEACP 2026\n\nLa Cumbre de Jefes de Estado y de Gobierno de la Organización de Estados de África, el Caribe y el Pacífico (OEACP) es uno de los principales eventos diplomáticos que reúne a los líderes de los países miembros.\n\nEsta cumbre constituye un momento estratégico para:\n• fortalecer la cooperación entre los Estados miembros\n• promover el desarrollo sostenible\n• discutir los grandes desafíos mundiales\n• fortalecer las asociaciones internacionales\n\nLa edición de 2026 se celebra en Malabo, capital de Guinea Ecuatorial.",
      oacpsTitle: "3. Presentación de la organización (OEACP)",
      oacpsContent:
          "Acerca de la OEACP\n\nLa Organización de Estados de África, el Caribe y el Pacífico (OEACP) es una organización intergubernamental que agrupa a 79 países miembros.\n\nSu misión es:\n• promover la cooperación política y económica\n• apoyar el desarrollo sostenible\n• fortalecer las asociaciones internacionales\n• defender los intereses comunes de sus Estados miembros\n\nLa OEACP desempeña un papel importante en las relaciones internacionales y las políticas de desarrollo.\n\nSitio oficial: www.oacps.org",
      featuresTitle: "4. Funcionalidades de la aplicación",
      features: [
        "Consultar el programa oficial de la Cumbre",
        "Acceder a foros y eventos",
        "Seguir las noticias y anuncios oficiales",
        "Acceder a la sala de prensa",
        "Obtener información sobre los procedimientos de acreditación",
      ],
      organizationTitle: "5. Información sobre la organización del evento",
      organizationContent:
          "Organización\n\nLa Cumbre se organiza bajo el alto patrocinio de la República de Guinea Ecuatorial, en colaboración con la Secretaría de la OEACP.\n\nLugar principal:\nCentro de Conferencias de Sipopo\nMalabo – Guinea Ecuatorial",
      contactTitle: "6. Contacto",
      contactContent:
          "Secretaría de la Cumbre OEACP\nMalabo – Guinea Ecuatorial\n\nEmail: summit2025@acp.int\nSitio oficial: www.oacps.org",
      legalTitle: "7. Información legal",
      legalContent:
          "© 2026 OEACP – Malabo Summit\nTodos los derechos reservados.\nEl uso de esta aplicación está sujeto a las políticas de privacidad y a las condiciones de uso de la organización.",
      versionTitle: "8. Versión de la aplicación",
      versionContent: "Versión: 1.0\nÚltima actualización: marzo 2026",
    ),
  };
}
