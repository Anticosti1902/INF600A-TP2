#
# Module qui specifie les details du format, textuel, pour la base de
# donnees des vins, notamment, le separateur, le format exact pour la
# lecture/ecriture dans le fichier, etc.
#

module VinTexte
  # Separateur pour les champs d'un enregistrement specificant un vin.
  SEPARATEUR = ':'

  SEP = SEPARATEUR  # Un alias pour alleger les expr. reg.

  # Methode pour creer un objet Vin a partir d'une ligne lue dans le
  # depot de donnees.
  def self.creer_vin( ligne )
    num_vin, date_achat, type, appellation, millesime, nom, prix, note, commentaire =
      ligne.chomp.split(SEP, 9)

    # Remarque concernant split dans l'appel precedente: Si un seul
    # argument est indique, alors les champs vides a la fin ne sont
    # pas conserves. Si un 2e argument K est specifie, alors on aura
    # jusqu'a K champs, dont certains possiblement vides... en autant
    # que K soit assez grand.  Sinon, le dernier champ contient tout
    # les elements terminaux:
    #
    # >> "a::b:c::".split(":")
    # => ["a", "", "b", "c"]
    # >> "a::b:c::".split(":", 6)
    # => ["a", "", "b", "c", "", ""]
    # >> "a::b:c::".split(":", 4)
    # => ["a", "", "b", "c::"]

    # Un appel a new doit recevoir les divers champs avec les types appropries.
    Vin.new( num_vin.to_i,
             to_date(date_achat),
             type.to_sym,
             appellation,
             millesime.to_i,
             nom,
             prix.to_f,
             note.empty? ? nil : note.to_i,
             commentaire.empty? ? nil : commentaire )
  end

  # Methode pour generer un objet Date a partir d'une specification de
  # date indiquee dans le depot: le format de ce dernier est comme
  # dans le devoir 1, donc pas tres approprie, car l'annee est
  # specifiee uniquement par les deux derniers chiffres, ce qui n'est
  # pas necessairement une bonne pratique :( Mais on laisse ainsi pour
  # faire exactement comme dans le devoir 1.
  #
  def self.to_date( date_achat )
    j, m, a = date_achat.split("/")

    Date.new( 2000 + a.to_i, m.to_i, j.to_i )
  end

  private_class_method :to_date

  # Methode pour sauvegarder un objet Vin dans le depot de donnees
  # indique par le fichier fich.
  #
  def self.sauver_vin( fich, vin )
    champs = [vin.numero.to_s,
              vin.date_achat.strftime("%d/%m/%y"),
              vin.type.to_s,
              vin.appellation,
              vin.millesime.to_s,
              vin.nom,
              sprintf( "%.2f", vin.prix ),
              vin.note? ? vin.note.to_s : '',
              vin.note? ? vin.commentaire : '']

    fich.puts champs.join(VinTexte::SEP)
  end
end
