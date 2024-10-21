# kube-project
1) настройка yc cli: yc init, выбор облака и зоны доступности (по токену, например y0_AgAAAAA8mPYyAATuwQAAAAEM8sX_AAA-Os8HL3pBubfzigMAjhgQe7df5g)
2) https://github.com/niko2892/kube-project/actions/workflows/yc-folder-create.yml создаю фолдер я вдндекс облаке, в аутпуте получаю id фолдедеа, сохраняю его в переменные репозитория
3) https://github.com/niko2892/kube-project/actions/workflows/yc-run-managed-kuber.yml разворачиваю kubernetes кластер получаю id кластера.
4) настраиваю кубконфиг по инструкции https://yandex.cloud/ru/docs/managed-kubernetes/operations/connect/create-static-conf#bash_2
5) установка nginx ingress controller и istio в кластер: 
6) сборка ,пуш и деплой приложений в кубер кластер. Перед сборкой выполняется проверка кодовой базы линтером (шаг не обязательный, нужен просто для демонстрации)
