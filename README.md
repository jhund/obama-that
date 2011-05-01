(See the original post on my blog [here](http://blog.echen.me/2011/05/01/bayesian-confidence-intervals-obamas-that-addition-and-informality-2/).)

# No "That" Left Behind?

I came across a [post](http://languagelog.ldc.upenn.edu/nll/?p=3109) on [Language Log](http://languagelog.ldc.upenn.edu/nll/?p=3109) last week giving some evidence that Obama tends to add *that* to the prepared version of his speeches.

For example, in a recent speech at George Washington University, the prepared speech was written as

    It's about the kind of future we want. It's about the kind of country we believe in.

but Obama spoke the two sentences at

    It's about the kind of future *that* we want. It's about the kind of country *that* we believe in.

(Amusingly, Liberman has the intuition that *that*-omission adds informality, while I have the opposite intuition.)

I wanted to get some more data to test whether Obama really does add *that* to his speeches, and to see whether his frequency of *that*-addition depends on the audience (e.g., maybe more formal speeches have less *that*-addition compared to rallies), so I scraped the [White House website](http://www.whitehouse.gov/briefing-room) for some speeches.

# Data

The [Speeches & Remarks](http://www.whitehouse.gov/briefing-room/speeches-and-remarks) section has transcripts of Obama's speeches as he actually delivered them, so I pulled the text from the 13 most recent for an "as delivered" dataset.

The [Weekly Address](http://www.whitehouse.gov/briefing-room/weekly-address) section, on the other hand, has the *as-prepared transcripts* of Obama's speeches, so I used the 11 most recent as an "as prepared" dataset.

Using this data, we can test whether the frequency of *that* in Obama's delivered speeches differs from the frequency of *that* in Obama's prepared weekly addresses.

# That-Frequencies

Here are the proportions of *that* in Obama's delivered remarks:

	delivered-remarks       2.59%
	delivered-remarks       3.34%
	delivered-remarks       2.35%
	delivered-remarks       2.36%
	delivered-remarks       1.98%
	delivered-remarks       3.23%
	delivered-remarks       3.27%
	delivered-remarks       2.43%
	delivered-remarks       2.29%
	delivered-remarks       3.04%
	delivered-remarks       1.81%
	delivered-remarks       2.41%
	delivered-remarks       2.40%

And here are the proportions in his prepared addresses:

	prepared-addresses      1.92%
	prepared-addresses      1.47%
	prepared-addresses      1.74%
	prepared-addresses      1.58%
	prepared-addresses      0.88%
	prepared-addresses      0.73%
	prepared-addresses      1.40%
	prepared-addresses      0.98%
	prepared-addresses      2.11%
	prepared-addresses      1.94%
	prepared-addresses      1.87%

Just by eye-balling, it's pretty evident that Obama's delivered remarks have a higher proportion of *that*, and we have enough data that a formal hypothesis test probably isn't necessary. But just for kicks, let's do one anyways. 

# Bayesian Confidence Intervals

Instead of going the standard frequentist route of performing a chi-square test or t-test, let's go the Bayesian route instead.

## Beta, Bayes, Barack

First, we use Bayes' Theorem to calculate P(*that*-frequency in Obama's delivered remarks is q | data): 

$$P(q | delivered data) \propto P(delivered data | q) P(q)$$

**First-term on the right**: If we pool the dataset together, so that the "as delivered" dataset has $n_1$ occurrences of *that* out of $M_1$ total words, then $P(delivered data | q) = q^{n_1} (1 - q)^{M_1 - n_1}$. 

**Second term on the right**: If we place an uninformative $Beta(1, 1)$ prior on $P(q)$ (recall that we can think of this as seeing exactly one prior delivered speech by Obama, where the speech consisted of two words, one of which was *that*), then (again recalling some properties of the Beta distribution) our posterior distribution is $P(q | delivered data) = Beta(n_1 + 1, M_1 - n_1 + 1)$.

Completely analogously, by placing an uninformative prior on the frequency $r$ of *that* in Obama's prepared addresses, we get a posterior distribution $P(r | prepared data) = Beta(n_2 + 1, M_2 - n_2 + 1)$.

## Applied to our Datasets

Our delivered dataset had $n_1 = 1239$ instances of *that* out of $M_1 = 49457$ total words, and our prepared dataset had $n_2 = 112$ instances of *that* out of $M_2 = 7301$ total words, so our posterior distributions are 

* $p(q | delivered data) = Beta(1239 + 1, 49457 - 1239 + 1) = Beta(1240, 48219)$
* $p(r | prepared data) = Beta(113, 7190)$.

Here's what these distributions look like, along with some R + ggplot2 code for generating them:

	library(ggplot2)

	x = seq(0, 1, by = 0.0001)
	y_delivered = dbeta(x, 1240, 48219)
	y_prepared = dbeta(x, 113, 8190)

	qplot(x, y_delivered, geom = "line", main = "P(that-frequency in delivered data = q | delivered data) ~ Beta(1240, 48219)", xlab = "q", ylab = "density")
	qplot(x, y_prepared, geom = "line", main = "P(that-frequency in prepared data = r | prepared data) ~ Beta(113, 8190)", xlab = "r", ylab = "density")

[![Delivered Posterior](http://dl.dropbox.com/u/10506/blog/obama-that/delivered-posterior.png)](http://dl.dropbox.com/u/10506/blog/obama-that/delivered-posterior.png)

[![Prepared Posterior](http://dl.dropbox.com/u/10506/blog/obama-that/prepared-posterior.png)](http://dl.dropbox.com/u/10506/blog/obama-that/prepared-posterior.png)

And together on the same plot:

	d = data.frame(x = c(x, x), y = c(y_delivered, y_prepared), which = rep(c("delivered", "prepared"), each = length(x)))
	qplot(x, y, colour = which, data = d, geom = "line", xlim = c(0, 0.04), ylab = "density")

[![Both Posterior](http://dl.dropbox.com/u/10506/blog/obama-that/both-posterior.png)](http://dl.dropbox.com/u/10506/blog/obama-that/both-posterior.png)

As we can see, the distributions are pretty much entirely disjoint, confirming our earlier suspicions that there's a distinct difference between the *that*-frequency of our two datasets.

## Confidence in the Difference

What we really want, though, is the probability distribution of the *difference* of the two Beta distributions $P(q - r > 0 | data)$, not the individual Beta distributions themselves. The difference of two Beta distributions doesn't have a closed form, so we use a simulation to calculate the probability:

	delivered_sim = rbeta(10000, 1240, 48219)
	prepared_sim = rbeta(10000, 113, 8190)
	diff = delivered_sim - prepared_sim

	qplot(diff, geom = "density")

	mean(diff) # 0.01147737
	length(diff[diff > 0]) / length(diff) # 1.0
	quantile(diff, c(0.025, 0.975)) # 0.008461888 0.014222934 

[![Difference](http://dl.dropbox.com/u/10506/blog/obama-that/difference.png)](http://dl.dropbox.com/u/10506/blog/obama-that/difference.png)

We see that $P(q - r > 0 | data)$ is effectively 0, so we're quite confident that $q > r$. Furthermore, we have $E[q - r] = 0.0115$ and a 95% credible interval for $q - r$ is $(0.0085, 0.0142)$.

# Hierarchical Models

In the analysis above, we pooled the documents in each dataset, treating all the delivered speeches as essentially one giant delivered speech  and likewise for the prepared transcripts. We also ignored the fact that the two datasets had something in common, namely, that they both deal with Obama.

This was fine for our problem, but sometimes we don't want to ignore these relationships. So instead, we could have built our model as follows:

* We can imagine that each of the delivered speeches has a slightly different *that*-frequency (due to, say, variations in the topic being discussed), but that these frequencies are related in some way. We can model this by saying that each individual delivered speech has an individual *that*-frequency $p_i$ drawn from a common distribution, say, $p_i \sim Beta(\alpha_d, \beta_d)$. This allows the *that*-frequencies of each delivered speech to differ, while still linking them with an overall structure.
* Similarly, we can model each prepared transcript as having an individual *that*-frequency $p'_i$ drawn from a separate common distribution, say, $p'_i \sim Beta(\alpha_p, \beta_p)$.
* Next, we might want to link the parameters of our beta distributions ($\alpha_d, \beta_d, \alpha_p, \beta_p$), so we could model them as coming from common Gamma distributions $\alpha_d, \alpha_p \sim Gamma(k_{\alpha}, \theta_{\alpha})$ and $\beta_d, \beta_p \sim Gamma(k_{\beta}, \theta_{\beta})$.

This gives us a *hierarchical model*, and I'll leave it at that, but perhaps I'll discuss them some more in a future post.