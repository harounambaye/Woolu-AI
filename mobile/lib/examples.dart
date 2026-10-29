import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'models.dart';

class IncidentOption {
  const IncidentOption(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

const incidentOptions = [
  IncidentOption('demande_code', 'Demande de code', PhosphorIconsBold.lockKey),
  IncidentOption('transfert_non_recu', 'Transfert non reçu', PhosphorIconsBold.paperPlaneTilt),
  IncidentOption('paiement_conteste', 'Paiement contesté', PhosphorIconsBold.storefront),
  IncidentOption('erreur_destinataire', 'Mauvais destinataire', PhosphorIconsBold.userSwitch),
  IncidentOption('fausse_confirmation', 'Fausse confirmation', PhosphorIconsBold.receiptX),
  IncidentOption('autre', 'Autre', PhosphorIconsBold.dotsThreeCircle),
];

class DemoExample {
  const DemoExample(this.title, this.subtitle, this.icon, this.incidentType, this.source, this.text);
  final String title;
  final String subtitle;
  final IconData icon;
  final String incidentType;
  final InputSource source;
  final String text;
}

// Scénarios synthétiques : marques, noms et numéros sont fictifs.
const demoExamples = [
  DemoExample(
    'SMS demandant un code',
    'Faux service client',
    PhosphorIconsDuotone.lockKey,
    'demande_code',
    InputSource.sms,
    'SMS reçu le 28/10 à 21h47 du 77 000 00 00 :\n'
        '"SERVICE CLIENT MOBILE MONEY : Bonjour, suite à une erreur système, un remboursement de 25 000 FCFA est en attente sur votre compte. '
        'Pour le débloquer, envoyez-nous IMMÉDIATEMENT le code à 6 chiffres que vous allez recevoir par SMS. '
        'Sans réponse sous 30 minutes, votre compte sera suspendu. Merci de votre confiance."',
  ),
  DemoExample(
    'Transfert débité, non reçu',
    '75 000 FCFA disparus',
    PhosphorIconsDuotone.paperPlaneTilt,
    'transfert_non_recu',
    InputSource.text,
    "Hier, le 27/10 vers 14h10, j'ai envoyé 75 000 FCFA à ma sœur à Ziguinchor depuis mon compte mobile money. "
        'J\'ai reçu le SMS : "Transfert de 75 000 FCFA effectué. Frais : 750 FCFA. Réf : TX-2610-48213. Nouveau solde : 12 340 FCFA." '
        "Mais ma sœur dit qu'elle n'a toujours rien reçu, ni SMS ni argent. Ça fait plus de 24 heures. Je ne sais pas qui contacter.",
  ),
  DemoExample(
    'Paiement contesté',
    'Commerçant, justificatifs incomplets',
    PhosphorIconsDuotone.storefront,
    'paiement_conteste',
    InputSource.text,
    "Je suis client d'une quincaillerie à Thiès. Samedi dernier, j'ai payé 42 500 FCFA par mobile money pour du matériel. "
        "J'ai eu un SMS de confirmation, mais je l'ai supprimé par erreur ; il me reste seulement une capture où l'on voit "
        '"Paiement marchand 42 500 FCFA" et une référence coupée qui commence par "PM-15...". '
        "Le commerçant dit qu'il n'a rien reçu et refuse de me donner le matériel sans un nouveau paiement. Il ne m'a pas donné de reçu.",
  ),
];
