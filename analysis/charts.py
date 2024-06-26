import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import matplotlib

# Legend locations for matplotlib
BEST = 0
UPPER_RIGHT = 1
UPPER_LEFT = 2
LOWER_LEFT = 3
LOWER_RIGHT = 4
RIGHT = 5
CENTER_LEFT = 6
CENTER_RIGHT = 7
LOWER_CENTER = 8
UPPER_CENTER = 9
CENTER = 10


def add_percentiles(df, period_column=None, column=None, show_outer_percentiles=True):
    """For each period in `period_column`, compute percentiles across that
    range.
    Adds `percentile` column.
    """
    deciles = np.arange(0.1, 1, 0.1)
    bottom_percentiles = np.arange(0.01, 0.1, 0.01)
    top_percentiles = np.arange(0.91, 1, 0.01)
    if show_outer_percentiles:
        quantiles = np.concatenate((deciles, bottom_percentiles, top_percentiles))
    else:
        quantiles = deciles
    df = df.groupby(period_column)[column].quantile(quantiles).reset_index()
    df = df.rename(index=str, columns={"level_1": "percentile"})
    # create integer range of percentiles
    df["percentile"] = df["percentile"].apply(lambda x: x * 100)
    return df


def deciles_chart(
    df,
    period_column=None,
    column=None,
    title="",
    ylabel="",
    show_outer_percentiles=True,
    show_legend=True,
    ax=None,
):
    """period_column must be dates / datetimes
    """
    sns.set_style("whitegrid", {"grid.color": ".9"})
    if not ax:
        fig, ax = plt.subplots(1, 1)
    df = add_percentiles(
        df,
        period_column=period_column,
        column=column,
        show_outer_percentiles=show_outer_percentiles,
    )
    linestyles = {
        "decile": {"color": "b", "line": "b--", "linewidth": 1, "label": "decile"},
        "median": {"color": "b", "line": "b-", "linewidth": 1.5, "label": "median"},
        "percentile": {
            "color": "b",
            "line": "b:",
            "linewidth": 0.8,
            "label": "1st-9th, 91st-99th percentile",
        },
    }
    label_seen = []
    for percentile in range(1, 100):  # plot each decile line
        data = df[df["percentile"] == percentile]
        add_label = False

        if percentile == 50:
            style = linestyles["median"]
            add_label = True
        elif show_outer_percentiles and (percentile < 10 or percentile > 90):
            style = linestyles["percentile"]
            if "percentile" not in label_seen:
                label_seen.append("percentile")
                add_label = True
        else:
            style = linestyles["decile"]
            if "decile" not in label_seen:
                label_seen.append("decile")
                add_label = True
        if add_label:
            label = style["label"]
        else:
            label = "_nolegend_"

        ax.plot(
            data[period_column],
            data[column],
            style["line"],
            linewidth=style["linewidth"],
            color=style["color"],
            label=label,
        )
    ax.set_ylabel(ylabel, size=15, alpha=0.6)
    if title:
        ax.set_title(title, size=18)
    # set ymax across all subplots as largest value across dataset
    ax.set_ylim([0, df[column].max() * 1.05])
    ax.tick_params(labelsize=12)
    ax.set_xlim(
        [df[period_column].min(), df[period_column].max()]
    )  # set x axis range as full date range
    ## add winter highlights
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2018', '04/01/2019']), color='cadetblue', alpha=0.25)
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2019', '04/01/2020']), color='cadetblue', alpha=0.25)
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2020', '04/01/2021']), color='cadetblue', alpha=0.25)
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2021', '04/01/2022']), color='cadetblue', alpha=0.25)
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2022', '04/01/2023']), color='cadetblue', alpha=0.25)
    ax.axvspan(*matplotlib.dates.datestr2num(['12/01/2023', '04/01/2024']), color='cadetblue', alpha=0.25)


    ## add summer highlights
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2018', '10/01/2018']), color='orangered', alpha=0.1)
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2019', '10/01/2019']), color='orangered', alpha=0.1)
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2020', '10/01/2020']), color='orangered', alpha=0.1)
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2021', '10/01/2021']), color='orangered', alpha=0.1)
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2022', '10/01/2022']), color='orangered', alpha=0.1)
    ax.axvspan(*matplotlib.dates.datestr2num(['06/01/2023', '10/01/2023']), color='orangered', alpha=0.1)


    plt.setp(ax.xaxis.get_majorticklabels(), rotation=90)
    # plt.setp(ax.yaxis.get_majorticklabels(), rotation=90)
    ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter('%m %Y'))
    ax.xaxis.set_major_locator(matplotlib.dates.MonthLocator(interval=6))
    if show_legend:#
        # Shrink current axis's height by 10% on the bottom
        box = ax.get_position()
        ax.set_position([box.x0, box.y0 + box.height * 0.1,
                        box.width*1.5, box.height * 0.9])

        # Put a legend below current axis
        ax.legend(loc='upper center', bbox_to_anchor=(0,1.02,1, 0.2),
                 ncol=3)

        # ax.legend(
        #     bbox_to_anchor=(1.1, 0.8),  # arbitrary location in axes
        #     #  specified as (x0, y0, w, h)
        #     loc=CENTER_LEFT,  # which part of the bounding box should
        #     #  be placed at bbox_to_anchor
        #     ncol=1,  # number of columns in the legend
        #     fontsize=12,
        #     borderaxespad=0.0,
        # )  # padding between the axes and legend
        #  specified in font-size units
    # rotates and right aligns the x labels, and moves the bottom of the
    # axes up to make room for them
    # plt.gcf().autofmt_xdate()
    return plt