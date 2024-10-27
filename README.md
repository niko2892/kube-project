# kube-project
1) настройка yc cli: yc init, выбор облака и зоны доступности (по токену, например y0_AgAAAAA8mPYyAATuwQAAAAEM8sX_AAA-Os8HL3pBubfzigMAjhgQe7df5g)
2) создать Yandex Object Storage для хранения terraform state
3) https://github.com/niko2892/kube-project/actions/workflows/yc-folder-create.yml создаю фолдер я вдндекс облаке, в аутпуте получаю id фолдедеа, сохраняю его в переменные репозитория
4) https://github.com/niko2892/kube-project/actions/workflows/yc-run-managed-kuber.yml разворачиваю kubernetes кластер получаю id кластера.
5) делегирую домен на рег.ру https://help.reg.ru/support/dns-servery-i-nastroyka-zony/rabota-s-dns-serverami/kak-propisat-dns-dlya-domena-v-lichnom-kabinete-reg-ru#0
6) настраиваю кубконфиг по инструкции https://yandex.cloud/ru/docs/managed-kubernetes/operations/connect/create-static-conf#bash_2
7) установка nginx ingress controller и istio в кластер: 
8) сборка ,пуш и деплой приложений в кубер кластер. Перед сборкой выполняется проверка кодовой базы линтером (шаг не обязательный, нужен просто для демонстрации)
9) логирование helm -n ofd upgrade ofd logging/kubernetes-logging --install --create-namespace