#!/usr/bin/env ruby

####################################################################
# Script pour gestion d'une cave a vins.
#
# Guy Tremblay, INF600A, automne 2018
####################################################################


require 'fileutils'
require_relative 'vin'
require_relative 'vin-texte'
require_relative 'motifs'


###################################################
# Constante globale.
###################################################

# Nom de fichier pour le depot par defaut.
DEPOT_DEFAUT = '.vins.txt'


###################################################
# Methodes pour debogage et traitement des erreurs.
###################################################

# Pour generer ou non des traces de debogage avec la function debug,
# il suffit d'ajouter/retirer '#' devant '|| true'.
DEBUG = false #|| true

def debug( *args )
  return unless DEBUG

  puts "[debug] #{args.join(' ')}"
end

def erreur( msg )
  STDERR.puts "*** Erreur: #{msg}"
  STDERR.puts

  puts aide if /Commande inconnue/ =~ msg

  exit 1
end

def verifier_arguments_en_trop( args )
  erreur "Argument(s) en trop: '#{args.join(" ")}'" unless args.empty?
end

def erreur_nb_arguments( *args )
  erreur "Nombre incorrect d'arguments: <<#{args.join(' ')}>>"
end


###################################################
# Methode d'aide: fournie, pour uniformite.
###################################################

def aide
  <<EOF
NOM
  #{$0} -- Script pour gestion d'une cave a vins

SYNOPSIS
  #{$0} [--depot=fich] commande [options-commande] [argument...]

COMMANDES
  aide          - Emet la liste des commandes
  ajouter       - Ajoute un vin
  init          - Cree une nouvelle base de donnees
                  (dans './#{DEPOT_DEFAUT}' si --depot n'est pas specifie)
  lister        - Liste les vins selon differents formats
  noter         - Attribue une note et un commentaire a un vin
                  (qui n'a pas encore ete note)
  selectionner  - Selectionne les vins matchant divers motifs/criteres
  supprimer     - Supprime un vin (qui n'a pas encore ete note)
  trier         - Trie selon divers criteres
EOF
end
###################################################
# Methodes pour manipulation du depot.
#
# Fournies pour simplifier le devoir et assurer au depart un
# fonctionnement minimal correct du logiciel.
###################################################
# Extension de String pour determiner si le depot represente stdin.
#
class String
  def stdin?
    self == "-"
  end
end
# Identifie le depot a utiliser, en analysant l'option specifiee sur
# la ligne de commande, si presente.
#
def depot_a_utiliser
  # A MODIFIER/COMPLETER!
  depot ||= DEPOT_DEFAUT

  depot
end

# Retourne la collection (Array) des vins lus dans le depot indique
#
# Erreurs:
#  - le depot n'existe pas
#
def charger_les_vins( depot )
  unless depot.stdin? || File.exist?(depot)
    erreur "Le fichier '#{depot}' n'existe pas!"
  end

  les_vins_lus = depot.stdin? ? STDIN.read.split("\n") : IO.readlines(depot)

  les_vins_lus.map { |ligne| VinTexte.creer_vin(ligne) }
end

# Sauve la collection (Array) des vins dans le depot indique
#
# Aucun effet si depot == "-"
#
def sauver_les_vins( depot, les_vins )
  return if depot != :stdout && depot.stdin?

  if depot == :stdout
    les_vins.each do |c|
      VinTexte.sauver_vin( STDOUT, c )
    end
  else
    FileUtils.cp depot, "#{depot}.bak"  # Copie de sauvegarde... juste au cas!

    # On sauve les vins dans le fichier associe au depot.
    #
    # Ici, il n'est pas approprie d'utiliser map, puisque la
    # collection resultante d'un map ne serait pas utilisee, puisqu'on
    # execute la boucle uniquement pour son effet de bord (i.e.,
    # ecriture dans le fichier).
    File.open( depot, "w" ) do |fich|
      les_vins.each do |c|
        VinTexte.sauver_vin( fich, c )
      end
    end
  end
end


#################################################################
# Les methodes pour les diverses commandes de l'application.
#################################################################

#=================================
# Commande init
#
# Arguments:  [--detruire]
#
# Erreurs:
#  - le depot existe deja et l'option --detruire n'a pas ete indiquee
#  - argument(s) en trop
#=================================
def init( depot )
  detruire = false
  if /^--detruire$/ =~ ARGV[0]
    detruire = true
    ARGV.shift
  end

  verifier_arguments_en_trop( ARGV )

  if File.exist? depot
    if detruire
      FileUtils.rm_f depot # On detruit le depot existant si --detruire est specifie.
    else
      erreur "Le fichier '#{depot}' existe.
              Si vous voulez le detruire, utilisez 'init --detruire'."
    end
  end

  FileUtils.touch depot
end

#=================================
# Commande lister
#
# Arguments: [--court|--long|--format=un_format]
#
# Valeur par defaut si option omise:
#   --long
#
# Erreurs:
# - argument(s) en trop
#=================================

FORMAT_COURT = '%I [%.2P$]: %A %M, %N'
FORMAT_LONG  = '%I [%T - %.2P$]: %A %M, %N (%D) => %n {%c}'

def lister( les_vins )
  nil # A MODIFIER/COMPLETER!
end

#=================================
# Commande ajouter
#
# Arguments: [--qte=99] [--type=chaine] appellation millesime nom prix
#
# Valeurs par defaut si options omises:
#   --qte=1
#   --type=rouge
#
# Erreurs:
# - depot invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - nombre invalide pour la quantite
# - nombre invalide pour le millesime
# - nombre invalide pour le prix (99.99)
# - argument(s) en trop
#=================================
def ajouter( les_vins )
  #Valeurs par défaut
    type = 'rouge'
    qte = 1
    appellation = ''
    arg1 = ARGV.shift
    if arg1.partition('=').first == "--qte"
      qte = arg1.partition('=').last
    elsif arg1.partition('=').first == "--type"
      type = arg1.partition('=').last
    else
      appellation = arg1
    end

    if appellation == ''
      arg2 = ARGV.shift
      if arg2.partition('=').first == "--qte"
        qte = arg2.partition('=').last
      elsif arg2.partition('=').first == "--type"
        type = arg2.partition('=').last
      else
        appellation = arg2
      end
    end

    last_line = File.open(depot_a_utiliser).to_a.last
    if !last_line.nil?
      numero = Motifs::NUM_VIN.match(last_line)[0].to_i
    else
      numero = -1
    end
    date = Time.now.strftime("%y/%m/%d")
    date = Date.parse date
    if appellation == ''
      appellation = ARGV.shift
    end
    millesime = ARGV.shift
    #puts millesime
    #puts Motifs::MILLESIME.match(millesime)
    #puts !Motifs::MILLESIME.match?(millesime)
    if !Motifs::MILLESIME.match?(millesime)
      puts "ALLO!"
      $stderr.puts "Le millesime entree de correspond pas a un nombre entier positif"
    end
    nom = ARGV.shift
    prix = ARGV.shift
    verifier_arguments_en_trop( ARGV )
    1.step(qte.to_i,1) { |i| les_vins << Vin.new( numero + i, date, type.to_sym, appellation, millesime.to_i, nom, prix.to_f) }
    return les_vins
end

#=================================
# Commande selectionner
#
# Arguments: [--bus|--non-bus|--tous] [motif]
#
# Valeur par defaut si options et motif omis:
#   --tous
#
# Erreurs:
#  - argument(s) en trop
#=================================
def selectionner( les_vins )
  nil # A MODIFIER/COMPLETER!
end

#=================================
# Commande supprimer
#
# Arguments: num_vin
#
# Erreurs:
# - depot invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - num_vin inexistant
# - num_vin deja note
# - argument(s) en trop
#=================================
def supprimer( les_vins )
  nil # A MODIFIER/COMPLETER!
end

#=================================
# Commande noter
#
# Arguments: numero_vin note commentaire
#
# Erreurs:
# - depot invalide (- ne peut pas etre utilise)
# - nombre incorrect d'arguments
# - vin avec le numero n'existe pas
# - vin deja note
# - nombre invalide pour la note (0 a 5)
# - argument(s) en trop
#=================================
def noter( les_vins )
  nil # A MODIFIER/COMPLETER!
end

#=================================
# Commande trier
#
# Arguments: [--appellation|--date-achat|--millesime|--nom|--numero|--prix|--cle=CLE] [--reverse]
#
# Valeur par defaut si options omises:
#   --numero
#
# Erreurs:
# - argument(s) en trop
#
# Les cles de tri sont comme dans le devoir 1 (les memes caracteres que pour to_s/lister):
#   I => numero
#   D => date_achat
#   T => type
#   A => appellation
#   M => millesime
#   N => nom
#   P => prix
#   n => note
#   c => commentaire
#=================================
def trier( les_vins )
  nil # A MODIFIER/COMPLETER!
end




#######################################################
# Les differentes commandes possibles.
#######################################################
COMMANDES = [:ajouter,
             :init,
             :lister,
             :noter,
             :selectionner,
             :supprimer,
             :trier,
            ]


#######################################################
# Le programme principal
#######################################################

#
# La strategie utilisee pour uniformiser le traitement des commandes
# est la suivante -- strategie differente de celle utilisee par ga.sh
# dans le devoir 1:
#
# - Une commande est mise en oeuvre par une methode auxiliaire.
#   Contrairement au devoir 1, c'est cette methode *qui modifie
#   directement ARGV* -- cela est possible en Ruby, alors que ce ne
#   l'etait pas en bash -- et ce selon les arguments consommes.  C'est
#   aussi cette methode qui s'assure, en fonction de ses arguments
#   requis, qu'il n'y a pas d'arguments en trop --- l'objectif est de
#   s'assurer de terminer l'execution aussitot que la presence
#   d'arguments en trop est detectee.
#
# - Si aucune erreur n'est signalee, la methode appelee pour realiser
#   une commande retourne un resultat dont le type depend de la
#   commande:
#
#   + ajouter, supprimer ou noter: liste modifiee des vins, qui est
#     sauvegardee dans le depot
#
#   + selectionner ou trier: sous-ensemble ou version reordonnee de la
#     liste des vins, emise sur stdout
#
#   + lister: chaine representant la sortie a emettre, emise sur stdout
#
#   + init: aucun resultat
#

begin
  # On definit le depot a utiliser, possiblement via l'option
  # specifiee sur la ligne de commande.
  depot = depot_a_utiliser

  debug "On utilise le depot suivant: #{depot}"

  # On analyse la commande indiquee en argument.
  commande = (ARGV.shift || :aide).to_sym
  if commande == :aide
    puts aide
    exit 0
  end

  erreur "Commande inconnue: '#{commande}'" unless COMMANDES.include?(commande)

  # La commande est valide: on l'execute.
  if commande == :init
    init(depot)
  else
    if [:ajouter, :noter, :supprimer].include?(commande) && depot.stdin?
      erreur "Le flux stdin ne peut pas etre utilise pour cette commande"
    end

    les_vins = charger_les_vins( depot )

    resultat = send commande, les_vins

    case commande
    when :ajouter, :noter, :supprimer
      sauver_les_vins( depot, resultat )
    when :selectionner, :trier
      sauver_les_vins( :stdout, resultat )
    when :lister
      print resultat  # Note: print n'ajoute pas de saut de ligne!
    end
  end
end
