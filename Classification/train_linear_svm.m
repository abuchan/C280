function model=train_linear_svm(features, labels)

model=train(labels+1, features, '-s 3 -c 1 -B 10', 'col');

