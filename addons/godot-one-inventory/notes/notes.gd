extends Node

"""
	OK ##  o slot de itens tem que ativar o drag and drop apenas se tiver um item no slot
	OK ## a cor do slot selecionado tem que voltar ao normal assim que o slot perder o foco
	OK ## criar as outras partes do corpo para equipar
	OK ## verificar os tipos dos drag and drops, exemplo:
	OK ## - um item só pode aceitar o drop se for do tipo esperado, exemplo:
	OK ## - um uma armadura só pode aceitar o equip se for do tipo equip (segunda aba de items)
	OK ## --- PODE SER USADO O NOME DO NODE PARA COMPARAÇÃO, EXEMPLO:
	OK ## O NO BODY ACEITA APENAS UM EQUIP COM ESSE TIPO (AFFECT?)
	OK ## informações do item equipado serão armazenadas em um dicionário para consulta,
	OK ## - e os devidos status adicionais serão consultados ali.
	
	###opts:###
	permitir o drag and drop de items em slots vazios
	permitir dividir a quantidade de items e armazenar em outro slot.
	OK ## permitir o drop de quantidade específica de tal item
	verificar se será possível o drag and drop de items nos slots vazios, pois, 
	-- o drag está sendo feito no slot, tem de haver um criterio...
	
	OK ## PASSAR O ITEM NO PARAMETRO DA FUNÇÃO PARA O CLIQUE
	
	OK ## ao desequipar um item o mesmo deverá voltar ao inventário, ao equipar ele fica 
	OK ## -- na região de equips e sai do inventario..
	
	OK ## essenciais:
		OK ## acertar o drag (body com body, arm com arm, etc..)
		OK ## realizar o drop, criar o popup de drop...
		OK ## acertar a forma de uso dos items
	
	OK ## colocar as cores em export vars...
	
	OK ## criar função do drop
	OK ## criar funcoes para equipar e usar itens
	
	OK ## resolver o bug em que no painel de items equipados quando clica em um e depois em outro, 
	OK ## -- e nesse por sua vez clica em desequipar, ele desequipa ambos.
	
	OK ## substituir equipamento já equipado...
	
	OK ## criar funcao clean_slot(panel)
	
	OK ## fazer função pra usar ref items...
	OK ## ao add o item, mostrar as mudanças imediatamente... (talvez, load_inventory() e load_items (equips, consumes...)
	OK ## permitir, atraves da view do editor, atribuir os tipos 'consume' e 'equipset'
	
	OK ## Ao add moedas mostrar as mudanças imediatamente!
	
	Talvez criar uma função para pegar (get) algum ref item...
	
	OK ## Bugs:
	OK ##	Ao selecionar um item em equips ou consume e selecionar o item equipado
	OK ##	ambos ficam selecionados, deve ficar apenas um selecionado.

"""

############################
#funções de teste...
#func _isconn():
#	print("#### CONNECTED TO SELF BUTTON ####")
#	for ap in self.get_signal_connection_list("button_up"):
#		print(ap)
##		print(ap.name, " - ", ap.default_args)
#	print("#### END SELF BUTTON ####")
#
#func _isconnOwner(owner_button):
#	print("#### CONNECTED TO OWNNER BUTTON ####")
#	for ap in owner_button.get_signal_connection_list("button_up"):
#		print(ap)
##		print(ap.name, " - ", ap.default_args)
#	print("#### END OWNER BUTTON ####")
#
#func _isconnDrop(dropButton):
#	print("#### CONNECTED TO DROP BUTTON ####")
#	for ap in dropButton.get_signal_connection_list("button_up"):
#		print(ap)
##		print(ap.name, " - ", ap.default_args)
#	print("#### END DROP BUTTON ####")

