require_relative 'test_helper'
require_relative '../vin'
require_relative '../vin-texte'

describe VinTexte do
  let(:date_achat) { Date.new(2018, 06, 10) }

  let(:chianti_ligne) { "2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65::" }
  let(:chianti_note_ligne) { "2:10/06/18:rouge:Chianti Classico:2014:Volpaia:26.65:4:Tres bon!" }

  let(:chianti) { Vin.new( 2, date_achat, :rouge, "Chianti Classico", 2014, "Volpaia", 26.65 ) }
  let(:chianti_note) { Vin.new( 2, date_achat, :rouge, "Chianti Classico", 2014, "Volpaia", 26.65, 4, "Tres bon!" ) }

  describe ".creer_vin" do
    it_ "cree un vin a partir d'une ligne sans note" do
      chianti = VinTexte.creer_vin chianti_ligne

      chianti.numero.must_equal 2
      chianti.date_achat.must_equal Date.new(2018, 6, 10)
      chianti.type.must_equal :rouge
      chianti.appellation.must_equal "Chianti Classico"
      chianti.millesime.must_equal 2014
      chianti.nom.must_equal "Volpaia"
      chianti.prix.must_equal 26.65

      refute chianti.note?
    end

    it_ "cree un vin a partir d'une ligne avec note" do
      chianti = VinTexte.creer_vin chianti_note_ligne

      chianti.numero.must_equal 2
      chianti.date_achat.must_equal Date.new(2018, 6, 10)
      chianti.type.must_equal :rouge
      chianti.appellation.must_equal "Chianti Classico"
      chianti.millesime.must_equal 2014
      chianti.nom.must_equal "Volpaia"
      chianti.prix.must_equal 26.65

      assert chianti.note?
      chianti.note.must_equal 4
      chianti.commentaire.must_equal "Tres bon!"
    end
  end

  describe ".sauver_vin" do
    let(:fich) { MiniTest::Mock.new }

    it "genere un enregistrement approprie pour un vin non note" do
      fich.expect( :puts, nil, [chianti_ligne] )

      VinTexte.sauver_vin( fich, chianti )

      fich.verify
    end

    it "genere un enregistrement approprie pour un vin note" do
      fich.expect( :puts, nil, [chianti_note_ligne] )
      VinTexte.sauver_vin( fich, chianti_note )

      fich.verify
    end
  end
end
