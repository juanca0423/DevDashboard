@{
  IncludeDefaultRules = $true

  # ...PERO desactivamos específicamente la que te está molestando
  ExcludeRules = @(
    #   'PSUseApprovedVerbs',      # Adiós a los warnings de go-symbols, py-symbols, etc.
    'PSAvoidUsingPlainTextForPassword' # (Opcional) Por si usas passwords en tus scripts de base de datos
  )
}
