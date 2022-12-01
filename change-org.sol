// SPDX-License-Identifier: MIT
// Trabalho 2 Criptomoedas e blockchain.

/*
    Proposta do projeto: Contrato Inteligente no Contexto de Baixo-Assinados de Cunho Social.

        A inspiração para este projeto é a plataforma www.change.org o qual tem o propósito de levar 
        mudanças políticas nos debates parlamentares e adminstrativos no brasil e mundo a fora. 
        Por meio de baixo-assinados on-line, cidadãos no execício do direito constitucional da iniciativa 
        popular, Constituição Federal Art. 14 III, podem criar e coletar assinaturas para uma causa específica.

        Contudo um problema pertinente a esta plataforma é a sua centralização, portanto problemas inerentes a esta estrutura
        seriam por exemplo, a necessidade de confiança na autoridade central na apuração das assinaturas, uma vez que 
        o processo de assinatura não é verificável através de outros meios senão a da própria entidade central.
        Outro problema é o risco de censura e perseguição de temas controversos.

        A proposta do projeto é fazer um protótipo de um contrato inteligente descentralizado na rede ethereum que possa
        mostrar uma possível alternativa para algumas destas questões, e que possam trazer mais confiaça e transparência no
        processo democrático.

        Ao longo do projeto serão discutidas também os problemas e benefícios que surgem com a possível adoção
        de um modelo como este no contexto de baixos-assinados.  

*/
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/Strings.sol";

contract ChangeOrg{
    string public nomeAutor;
    string public titulo;
    string public corpo;
    address private autor;
    string public imagem; // puxar do ipfs
    
    bool public ativo;
    bool public metaAtingida; // talvez uma pure function? 

    uint public inicio;
    uint public termino;

    uint public nAssinaturas;
    uint public metaAssinaturas;

    //garante assinatura unica por conta. 
    mapping(address => string) private assinaturas; // assinatura e nome declarado do assinante. 
    
    // comentario sobre o baixo assinado

    // criar baixo assinado, assinar junto com account do criador.
    constructor(string memory _nomeAutor,string memory _titulo, 
        string memory _corpo,string memory _imagem,
        uint _duracaoDias,
        uint _metaAssinaturas){

        require(keccak256(bytes(_nomeAutor))!=keccak256(bytes("")), "nome autor nao pode ser vazio");
        require(keccak256(bytes(_titulo))!=keccak256(bytes("")), "titulo nao pode ser vazio");
        require(keccak256(bytes(_corpo))!=keccak256(bytes("")), "corpo nao pode ser vazio");
        require(_duracaoDias!=0, "duracao de dias nao pode ser zero");
        require(_metaAssinaturas!=0, "meta de assinaturas nao pode ser zero");
        
        autor = msg.sender;
        nomeAutor = _nomeAutor;
        titulo = _titulo;
        corpo = _corpo;
        imagem = _imagem;
        
        metaAssinaturas = _metaAssinaturas;

        require(_duracaoDias > 0, "duracao de dias deve ser maior que zero.");
        inicio = block.timestamp;
        termino = inicio + _duracaoDias * 1 days;

        ativo = true;
    }
    // ver porcentagem meta - pure function, se fosse um state gastaria aumentaria o gasto de gas.
    function verProgresso() public view returns(string memory) {
        return string.concat("Porcentagem Progresso: ", Strings.toString(progresso()),"%");
    }

    function progresso() private view returns(uint){
        return nAssinaturas*100/metaAssinaturas;
    }

    // retorna true para sucessful e false para erro
    function adicionarAssinatura(string memory _nome) external returns(bool){
        require(ativo, "Termino do baixo-assinado. Fechado para mais votacoes");
        require(keccak256(bytes(_nome))!=keccak256(bytes("")), "nome nao pode ser vazio");

        // fechar baixo assinado caso término
        if (termino<block.timestamp){
            ativo = false;
            return false;
        }
        // verifica se adress já assinou ou não, se nao assinou conteudo do map eh ""
        require(keccak256(bytes(assinaturas[msg.sender])) == keccak256(bytes("")),
         "ja assinado com esta account. duas assinaturas com a mesma conta nao eh permitido.");
        
        //contabliziar assinatura e registrar nome
        assinaturas[msg.sender] = _nome;
        nAssinaturas++;

        // atualizar meta atingida
        if (!metaAtingida){
            if (nAssinaturas >= metaAssinaturas){
                metaAtingida = true;
            }
        }
        return true;
    }

    // get address from signed message
}