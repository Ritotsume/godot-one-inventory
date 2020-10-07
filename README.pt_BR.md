# Godot One Inventory

>[en][en_version]

Um inventário para uso na Godot engine (testado na versão 3.2.x)

O que esse plugin faz:

- armazena itens de vários tipos.
- permite personalizar a cor de seleção do item e as imagens dos botões.

O que pretendo adicionar:

- tela de background personalizada totalmente funcional.
- reorganizar os itens com drag and drop.
- possibilitar equipamentos separados, por exemplo: arma, elmo, armadura, botas, luvas.
- mais opções de personalização.
- e outras coisinhas que devo adicionar aqui futuramente.

## Uma breve descrição

O plugin possui algumas script vars:

![script vars][script_vars]

**Background:** Pretende ser uma tela de background personalizada. (não concluído)

**Button Normal:** Aparência dos botões em estado normal.

**Button Pressed:** Aparência dos botões ao serem pressionados.

**Active Color:** A cor da caixa de seleção do item quando o mesmo estiver selecionado.

**Money Texture:** A imagem que representará o dinheiro a ser mostrado no inventário.

**Usable Are Visible:** Itens "usáveis" estarão visíveis no inventário? Padrão: falso.

**Item Types:** Por padrão esse plugin aceita 3 tipos de itens.
- **Consumable:** Itens consumíveis, tais como: poções, elixires, etc.
- **Equipments:** Equipamentos: armaduras.
- **Usable:** Itens de progressão, itens que poderão ou não ser usados dependendo do avanço na aventura (game).

>Atenção: os `item types` devem ser condizentes com o que estiver em `attrib.type`.

Para uso desse plugin espera-se que o item a ser inserido tenha a seguinte estrutura:

    "gundar": {
        "icon": "res://sprites/button_fight_released.png",
        "name": "Heavy Armor of Gundar",
        "info": "Armor that defends against various types of damage.",
        "value": 9,
        "amount": 1,
        "attrib": {
            "type": 1,
            "affect": "equipset",
            "effect": "defense",
            "value": 12
        }
    }

Essa estrutura representa o seguinte:

- **gundar:** Essa é a chave do item, deve ser única para cada item.
- **icon:** Uma imagem que irá representar visualmente o item.
- **name:** O nome do item como será mostrado ao jogador quando este consultar a descrição o item.
- **info:** Informação do item.
- **value:** Um valor para o item ao ser vendido em lojas de NPC's.
- **amount:** Quantidade disponível para esse item.
- **attrib:** Atributos e efeitos do item.
- **attrib.type:** Tipo do item, por exemplo, equipamento, consumível, de uso comum, etc.
- **attrib.affect:** O que é afetado por este item, os equipamentos, energia, força, etc.
- **attrib.effect:** O efeito esperado ao usar o item, aumento, decremento, etc.
- **attrib.value:** O valor do efeito, o quanto irá afetar attrib.effect.

De todos esses, apenas os seguintes são obrigatórios:

- **gundar:** A chave do item, que deve ser única para cada item.
- **icon:** Uma imagem para o item é importante.
- **amount:** O item deve conter uma quantidade > 0.
- **attrib.type:** O item precisar ter um tipo, caso seja equipamentos utilizar o painel com as *script vars* e especificar os tipos: *equipments*, *consumable*, *usable*. De modo que fiquem coerentes com os itens que serão inseridos no inventário. Por exemplo, posso ter uma **enum** que possua esses valores, com isso, vou definir em *script vars* os respectivos valores para cada um, o plugin fará o resto.

## Instalação

1. Copie a pasta *addons* para a raiz do projeto.
2. Habilite o plugin em (Configurações do Projeto > Plugins).
3. Parabéns! Agora você pode usar o plugin.

## Usando o plugin

1. Obtenha a instância do plugin:  
`onready var inventory = load("res://addons/godot-one-inventory/inventory.tscn").instance()`  
2. Connect os sinais necessários:  
`inventory.connect("used_consume_item", self, "_on_consumed_item")`  
`inventory.connect("used_usable_item", self, "_on_used_usable")`  
`inventory.connect("equipped_item", self, "_on_equipped_item")`  
3. Anexe ele à sua viewport (ou cena):  
`add_child(inventory)`  
4. Use o método *set_visible* para mostrar o inventário. Coloque essa chamada em algum botão que irá mostrar o inventário:  
`inventory.set_visible(true)`

## Screenshots

![screen one][sc_one]

![screen two][sc_two]

Espero que este plugin possa ajudar você. Se ele foi útil, considere pagar-me um café, obrigado! [ByMeACoffee][bmc]

Disponível sob licensa MIT. [Licensa][license]

[script_vars]: ./screenshots/script_vars.png "Script Vars"
[sc_one]: ./screenshots/one_sc.png "Screenshot One"
[sc_two]: ./screenshots/two_sc.png "Screenshot Two"

[bmc]: https://buymeacoff.ee/gianscardua "By Me A Coffee"
[license]: LICENSE "Licensa"
[en_version]: README.md "English Version"
