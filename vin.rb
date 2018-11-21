require_relative 'dbc'
require_relative 'motifs'

require 'date'

#
# Objet pour modeliser un vin.
#
# Tous les champs d'une instance sont immuables (non modifiables) *a
# l'exception* des champs qui indiquent la note et le commentaire.
#
class Vin
  include Comparable

  READERS = [:numero, :date_achat, :type, :appellation, :millesime, :nom, :prix]
  ACCESSORS = [:note, :commentaire]

  # Attributs et methodes de classe.
  #
  # Une classe etant un objet, elle possede elle-meme des attributs
  # d'instance (!).  C'est ce qui est utilise ci-bas pour identifier
  # le plus grand numero de vin rencontre (pour assurer l'unicite) et
  # pour les methodes de comparaison de l'operateur <=> (i.e., les
  # champs a utiliser pour comparer deux vins).
  #

  @comparateurs = [:numero] # Comparateur par defaut: juste le numero.

  # Methodes de le classe Vin.
  class << self
    attr_reader :comparateurs # Appel: Vin.comparateurs
    attr_accessor :numero_max # Appels: Vin.numero_max et Vin.numero_max = ...

    # Appel: Vin.comparateurs = ...
    def comparateurs=( cs )
      DBC.require( cs.all? { |c| (READERS + ACCESSORS).include?(c) },
                   "Comparateur(s) invalide(s): #{cs}" )

      @comparateurs = cs
    end
  end

  # Methodes pour acces (lecture) aux attributs (readers) d'une instance.
  # A COMPLETER.
  def numero
    @numero
  end

  def date_achat
    @date_achat
  end

  def type
    @type
  end

  def appellation
    @appellation
  end

  def millesime
    @millesime
  end

  def prix
    @prix
  end

  def nom
    @nom
  end

  def note
    @note
  end

  def commentaire
    @commentaire
  end


  # Methode de classe utilisee pour la construction, en cours
  # d'execution du script, de nouveaux objets. Ces objets seront
  # ulterieurement ajoutes a la BD lors de la fin de l'execution du
  # script.
  #
  def self.creer( type, appellation, millesime, nom, prix )
    # On definit les attributs generes.
    numero = Vin.numero_max.nil? ? 0 : Vin.numero_max + 1
    date_achat = Time.now.to_date

    # On cree la nouvelle instance -- avec les bons types.
    new( numero, date_achat, type.to_sym, appellation, millesime.to_i, nom, prix.to_f )
  end

  # Methode d'initialisation d'un vin.
  #
  # Les arguments doivent tous etre du type approprie, i.e., les
  # conversions doivent avoir ete faites au prealable.
  #
  def initialize( numero, date_achat,
                  type, appellation, millesime, nom, prix,
                  note = nil, commentaire = nil )
    DBC.require( numero.kind_of?(Integer) && numero >= 0,
                 "Numero de vin incorrect -- doit etre un Integer non-negatif: #{numero}!?" )
    DBC.require( date_achat.kind_of?(Date),
                 "Date d\'achat incorrecte -- doit etre une Date: #{date_achat} (#{date_achat.class})!?" )
    DBC.require( type.kind_of?(Symbol),
                 "Type de vin incorrect -- doit etre un Symbol: #{type} (#{type.class})!?" )
    DBC.require( millesime.kind_of?(Integer) && millesime >= 0,
                 "Millesime de vin incorrect -- doit etre un Integer non-negatif: #{millesime}!?" )
    DBC.require( prix.kind_of?(Float) && prix >= 0.00,
                 "Prix de vin incorrect -- doit etre un Float non-negatif: #{prix}!?" )
    # A COMPLETER.
    @numero = numero
    @date_achat = date_achat
    @type = type
    @appellation = appellation
    @millesime = millesime
    @prix = prix
    @nom = nom
    @note = note
    @commentaire = commentaire
    Vin.numero_max = Vin.numero_max ? [Vin.numero_max, numero].max : numero
  end

  def bu?
    !@note.nil?
  end

  alias_method :note?, :bu?

  # Retourne la note d'un vin ayant ete bu.
  #
  def note
    DBC.require( bu?, "Vin non bu: La note n'est pas definie" )

    @note
  end

  # Retourne le commentaire d'un vin ayant ete bu.
  #
  def commentaire
    DBC.require( bu?, "Vin non bu: Le commentaire n'est pas defini" )

    @commentaire
  end

  # Ajoute une note et un commentaire a un vin n'ayant pas encore ete
  # bu.
  #
  def noter( note, commentaire )
    # A COMPLETER.
  end

  #
  # Formate un vin selon les indications specifiees par le_format.
  #
  # Les items de specification de format sont les memes que dans le
  # devoir 1:
  #   I => numero
  #   D => date_achat
  #   T => type
  #   A => appellation
  #   M => millesime
  #   N => nom
  #   P => prix
  #   n => note
  #   c => commentaire
  #
  # Des indications de largeur, justification, etc. peuvent aussi etre
  # specifiees, par exemple, %-10T, %-.10T, etc.
  #
  # NOTE: Pour la date d'achat, voici comment convertir une Date dans
  # le format approprie: date_achat.strftime("%d/%m/%y"),
  #
  def to_s( le_format = nil )
    # BIDON: A MODIFIER/COMPLETER.
    format( "%s => %s", numero, nom )
  end


  #
  # Ordonne les vins selon le numero.
  #
  def <=>( autre )
    # A MODIFIER/COMPLETER.
    nil
  end

end
