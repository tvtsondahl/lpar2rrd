PATH := /bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/libexec

nameContainer=lpar2rrd
tagVer=0.1

.PHONY: $(nameContainer)

$(nameContainer):
	docker build --compress \
		--no-cache \
		--force-rm \
		-t $(nameContainer):$(tagVer) .
#		-t evergreen.tivit.com/tivit/$(nameContainer):latest \
#		-t evergreen.tivit.com/tivit/$(nameContainer):$(tagVer) .

@echo
@echo "===== ATENCAO !!! ATENCAO !!! ATENCAO ====="
@echo
@echo "Imagem $(nameContainer):latest criada com sucesso"
# @echo "Voce DEVE fazer 'docker push evergreen.tivit.com/tivit/$(nameContainer):latest' manualmente"
@echo