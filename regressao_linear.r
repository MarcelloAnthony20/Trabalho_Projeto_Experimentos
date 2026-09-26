library("corrplot")
library("car")
library("lmtest")

# dataset <- read.csv("Complete_Dataset.csv", dec=",")
dataset <- read.csv("Complete_Dataset.csv")
for (v in names(dataset)) {
    if (is.character(dataset[[v]])) {
        conv <- suppressWarnings(as.numeric(gsub(",", ".", dataset[[v]])))
        if (mean(is.na(conv)) < 0.1) dataset[[v]] <- conv   # só se for mesmo número
    }
}

dataset_numerico <- dataset[, sapply(dataset, is.numeric)]
matriz_correlacao <- cor(dataset_numerico)
png("matriz_correlacao.png", width = 1200, height = 1200, res = 150)
corrplot(matriz_correlacao, method = "color", type = "upper", tl.cex = 0.5, cl.cex = 0.5)
dev.off()

# Original: vars_remover <- c("ADG", "FINAL_WEIGHT")
vars_remover <- c("ADG", "FINAL_WEIGHT", "ANIMAL", "PERIOD")
todas_var <- names(dataset_numerico)
vars_independentes <- todas_var[!todas_var %in% vars_remover]

#feito para não dar erro no vif, porque quando esse comando dataset <- read.csv("Complete_Dataset.csv")
#trouxe mais colunas algumas que são cópias de outras.
equacao <- as.formula(paste("ADG ~ ", paste(vars_independentes, collapse = " + ")))
modelo_temp <- lm(equacao, data = dataset_numerico)
redundantes <- names(coef(modelo_temp))[is.na(coef(modelo_temp))]
cat("Removidas por redundância:", redundantes, "\n")
vars_independentes <- vars_independentes[!vars_independentes %in% redundantes]

corte_vif <- 5
continuar <- TRUE
while(continuar){
    equacao <- as.formula(paste("ADG ~ ", paste(vars_independentes,
                                        collapse = " + ")))
    modelo_temp <- lm(equacao, data=dataset_numerico)
    vif_temp <- vif(modelo_temp)
    maior_vif <- max(vif_temp)
    if(maior_vif >= corte_vif){
        pior_variavel <- names(vif_temp)[which.max(vif_temp)]
        vars_independentes <- vars_independentes[!vars_independentes %in% pior_variavel]
        cat("Removida variável:", pior_variavel, "(VIF=", maior_vif, ")\n")
    }else{
        continuar <- FALSE
    }
}
cat("\nVariáveis finais:", paste(vars_independentes, collapse = " + "), "\n")

modelo_final <- step(modelo_temp, direction="both", trace=0)

summary(modelo_final)  


shapiro.test(modelo_final$residuals)
bptest(modelo_final)
durbinWatsonTest(modelo_final)
