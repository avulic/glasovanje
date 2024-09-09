pragma solidity >=0.4.22 <0.7.0;


contract Glasovanje {
    
    address public vlasnikGlasovanja;
    string public nazivGlasovanja;
    
    uint brojGlasaca;
    mapping(uint => address) public glasaci;
    
    
    struct Glas {
        address adresaGlasaca;
        uint idOpcije;
    }
    //mapping(uint => Glas) public glasovi;
    uint brojGlasova;
    
    struct Opcija{
        uint id;
        bytes32 naziv;
        uint brojGlasova;
    }
    uint brojOpcijaPoPrijedlogu;
    
    struct Prijedlog {
        uint id;
        string naziv;
        Stanje stanje;
        mapping(uint => Opcija) opcije;
        mapping(address => Glas) glasovi;
        uint idPobjednika;
        uint brojOpcija;
    }
    mapping(uint => Prijedlog) public prijedlozi;
    uint brojPrijedloga;
    
    enum Stanje{ Kreiran, Pocetak, Zavrsetak }
    //StanjeGlasovanja public stanje;
    
    constructor(string memory _nazivGlasovanja, string memory _nazivPrijedloga, bytes32[] memory _naziviOpcija) public {
        vlasnikGlasovanja = msg.sender;
        nazivGlasovanja = _nazivGlasovanja;
        
        kreirajPrijedlog(_nazivPrijedloga, _naziviOpcija);
    }
    
    modifier provjeraStanja(uint idPrijedolga, Stanje _stanje){
        require(prijedlozi[idPrijedolga].stanje == _stanje);
        _;
    }
    
    modifier provjeraVlasnika(){
        require(msg.sender == vlasnikGlasovanja);
        _;
    }
    
    event glasaciDodani();
    function dodajGlasace(address[] memory _glasaci) public provjeraVlasnika{
       for(uint i = 0; i < _glasaci.length; i++){
            glasaci[i] = _glasaci[i];
        }
        
        emit glasaciDodani();
    }
    
    event prijedlogKreiran(uint idPrijedlog);
    function kreirajPrijedlog(string memory _nazivPrijedloga, bytes32[] memory _naziviOpcija) public provjeraVlasnika{
        Prijedlog memory p = Prijedlog({
            id : brojPrijedloga++,
            naziv : _nazivPrijedloga,
            stanje : Stanje.Kreiran,
            idPobjednika : 0,
            brojOpcija : 0
        });
        
        brojOpcijaPoPrijedlogu = 0;
        for(uint i = 0; i < _naziviOpcija.length; i++){
            Opcija memory o = Opcija({
                id : ++brojOpcijaPoPrijedlogu,
                naziv : _naziviOpcija[i],
                brojGlasova : 0
            });
            prijedlozi[brojPrijedloga].opcije[brojOpcijaPoPrijedlogu] = o;
        }
        p.brojOpcija = brojOpcijaPoPrijedlogu;
        prijedlozi[brojPrijedloga] = p;
        
        emit prijedlogKreiran(p.id);
    }
    
    event glasovanjePokrenuto(uint idPrijedlog);
    function pokreniGlasanje(uint _brojPrijedloga) public provjeraStanja(_brojPrijedloga, Stanje.Kreiran) provjeraVlasnika{
        prijedlozi[_brojPrijedloga].stanje = Stanje.Pocetak;
        emit glasovanjePokrenuto(_brojPrijedloga); 
    }
    
    event korisnikGlasao(address voter);
    function dodjelaGlasa(uint _brojPrijedloga, uint _brojOpcija) public provjeraStanja(_brojPrijedloga, Stanje.Pocetak){
        if(_brojOpcija == 0)
            revert("Opcija 0 se ne koristi");
        
        if(prijedlozi[_brojPrijedloga].glasovi[msg.sender].idOpcije == 0){
            prijedlozi[_brojPrijedloga].glasovi[msg.sender] = Glas({
                adresaGlasaca : msg.sender,
                idOpcije : _brojOpcija
            });
            prijedlozi[_brojPrijedloga].opcije[_brojOpcija].brojGlasova++;
            
            emit korisnikGlasao(msg.sender);
        }else{
            revert("Krosnik je vec glasao");
        }
        
    }
    
    event glasovanjeZatvoreno(uint idPrijedlog, uint pobjednik);
    function zatvoriGlasanje(uint _brojPrijedloga) public provjeraStanja(_brojPrijedloga, Stanje.Pocetak) provjeraVlasnika{
        prijedlozi[_brojPrijedloga].stanje = Stanje.Zavrsetak;
        Opcija memory max;
        for(uint i = 1; i <= prijedlozi[_brojPrijedloga].brojOpcija; i++){
            if(prijedlozi[_brojPrijedloga].opcije[i].brojGlasova > max.brojGlasova){
                max = prijedlozi[_brojPrijedloga].opcije[i];
            }  
        }
        prijedlozi[_brojPrijedloga].idPobjednika = max.id;
        
        emit glasovanjeZatvoreno(_brojPrijedloga, prijedlozi[_brojPrijedloga].idPobjednika);
    }
    
    function pobjednik(uint _brojPrijedloga) public view provjeraStanja(_brojPrijedloga, Stanje.Zavrsetak) returns(bytes32 nazivOpcije){
        return prijedlozi[_brojPrijedloga].opcije[prijedlozi[_brojPrijedloga].idPobjednika].naziv;
    }
}






//["0x416e746500000000000000000000000000000000000000000000000000000000","0x4d696c6500000000000000000000000000000000000000000000000000000000","0x4e656e6f00000000000000000000000000000000000000000000000000000000"]
//
//glasaciA
//["0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C","0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB","0x583031D1113aD414F02576BD6afaBfb302140225"]






