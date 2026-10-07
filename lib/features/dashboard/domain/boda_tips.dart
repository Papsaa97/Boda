/// Statické tipy od Bódi podle měsíce. Žádná AI, jen sezónní moudra.
///
/// Každý den se vybere jiný tip z aktuálního měsíce, takže se tip
/// během dne nemění a druhý den je nový.
abstract final class BodaTips {
  static const Map<int, List<String>> _byMonth = {
    1: [
      'Leden je čas na plánování. Projdi si osiva a zkontroluj, co ti prošlo.',
      'Sníh na záhonech je přikrývka, ne nepřítel. Nech ho tam.',
      'Naostři a naolej nářadí, na jaře nebude čas.',
    ],
    2: [
      'Papriky a chilli potřebují dlouhý start, únor je ideální na výsev za oknem.',
      'Prořež ovocné stromy, dokud spí. Řez za mrazu pod −5 °C ale vynech.',
      'Zkontroluj uskladněné hlízy a jablka, jedno shnilé nakazí celou bednu.',
    ],
    3: [
      'Jakmile jde půda zpracovat, vysej ředkvičky a hrách přímo ven.',
      'Rajčata na sadbu teď, ať jsou v květnu připravená ven.',
      'Neryj mokrou půdu. Když se lepí na rýč, dej jí ještě pár dní.',
    ],
    4: [
      'Duben je zrádný. Mladé rostliny měj po ruce netkanou textilii.',
      'Mulč drží vláhu i plevel na uzdě. Na teplé záhony s ním počkej.',
      'Sadbu otužuj postupně, nejdřív pár hodin venku ve stínu.',
    ],
    5: [
      'Po zmrzlých mužích (12.–14. 5.) můžeš ven s rajčaty a okurkami.',
      'Zalévej ráno ke kořenům, ne večer na listy. Plísně ti poděkují.',
      'I plevel roste, když se nedíváš! Pár minut denně ušetří hodiny.',
    ],
    6: [
      'Rajčatům vyštipuj zálistky, ať síla jde do plodů.',
      'Trávník v horku nesekej nakrátko, nech ho aspoň 5 cm.',
      'Sbírej jahody ráno, kdy jsou nejchutnější a nejpevnější.',
    ],
    7: [
      'Ve vedru zalévej méně často, ale vydatně. Kořeny půjdou hlouběji.',
      'Vysej druhou várku fazolí a mrkve na podzimní sklizeň.',
      'Odkvetlé květiny ostříhej, pokvetou znovu.',
    ],
    8: [
      'Česnek a cibuli sklízej, až polovina natě zežloutne.',
      'Konec srpna je ideální na výsev nového trávníku.',
      'Zapiš si, které odrůdy se letos osvědčily. Za rok to nebudeš vědět.',
    ],
    9: [
      'Sázej cibuloviny na jaro: tulipány, narcisy, krokusy.',
      'Nezralá rajčata před mrazem otrhej, dozrají v teple doma.',
      'Spadané listí je zlato do kompostu, jen ho promíchej s trávou.',
    ],
    10: [
      'Říjen je čas na výsadbu česneku, stroužky 5 cm hluboko.',
      'Vyhrab spadané listí z trávníku, pod ním trávník plesniví.',
      'Vyprázdni hadice a zahradní kohoutek dřív, než přijde mráz.',
    ],
    11: [
      'Prázdné záhony přikryj mulčem nebo vysej zelené hnojení.',
      'Mladé stromky obal proti okusu zajíci.',
      'Ukliď a vysuš nářadí, na jaře ti poděkuje.',
    ],
    12: [
      'Zahrada odpočívá, ty můžeš taky. Prolistuj si deník za celý rok.',
      'Krmítko pro ptáky je dobrá investice, v létě ti pomůžou se škůdci.',
      'Zkontroluj, jestli sníh neláme větve keřů, a opatrně ho setřes.',
    ],
  };

  static String forDate(DateTime date) {
    final tips = _byMonth[date.month]!;
    return tips[date.day % tips.length];
  }
}
