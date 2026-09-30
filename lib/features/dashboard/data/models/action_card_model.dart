class ActionCard{
  final String message;
  final String cta;
  final Function()? onTap;

  ActionCard( {required this.message, required this.cta, this.onTap});
}