# Motifs representant les divers attributs pour un vin.
#
# Utilises lors de la lecture d'une specification de vin (via la ligne
# de commande ou via stdin) pour assurer que les champs sont du bon
# format.
#
# Pour les champs nom, appellation et commentaire, on suppose que
# n'importe quels caracteres peuvent etre utilises, a l'exception du
# separateur.  C'est donc ce qui est formalise dans les motifs
# indiques (CHAINE).
#
# Rappel: les trois facons suivantes permettent de definir un meme
# objet Regexp:
#
#   /.../
#   %r{...}
#   Regepx.new("...")

require_relative 'vin-texte'

module Motifs
  # A MODIFIER/COMPLETER.
  NUM_VIN = %r{[0-9][0-9]*}

  DATE = %r{}

  CHAINE = %r{"(?:[^"#{VinTexte::SEP}]+)"|'(?:[^'#{VinTexte::SEP}]+)'|(?:[^\s#{VinTexte::SEP}]+)}

  APPELLATION = CHAINE
  NOM = CHAINE
  COMMENTAIRE = CHAINE
  #TROUVER_FORMATS =  %r{%[^IDTAMNPnc]*[IDTAMNPnc]{1}}

  MILLESIME = %r{}
  PRIX = %r{}

  NOTE_MIN=0
  NOTE_MAX=5
  NOTE = %r{}
end
